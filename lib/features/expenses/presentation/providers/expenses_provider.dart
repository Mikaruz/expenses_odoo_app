import 'package:oh_expenses_app/features/auth/auth.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/infrastructure.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses_provider.g.dart';

@Riverpod(keepAlive: true)
ExpensesDatabase expensesDatabase(Ref ref) {
  final database = ExpensesDatabase();
  ref.onDispose(database.close);
  return database;
}

@Riverpod(keepAlive: true)
LocalExpensesRepository localExpensesRepository(Ref ref) {
  return LocalExpensesRepositoryImpl(
    DriftLocalExpensesDatasource(ref.watch(expensesDatabaseProvider)),
    ReceiptStorageDatasourceImpl(),
  );
}

@Riverpod(keepAlive: true)
ExpensesRepository remoteExpensesRepository(Ref ref) {
  return ExpensesRepositoryImpl(ExpensesDatasourceImpl());
}

@riverpod
Future<String?> currentAccountScope(Ref ref) async {
  final user = ref.watch(authProvider).user;
  if (user == null) return null;

  final storage = KeyValueStorageServiceImpl();
  final odooUrl = await storage.getValue<String>('odooUrl');
  final database = await storage.getValue<String>('odooDatabase');
  if (odooUrl == null || database == null) return null;

  final normalizedUrl = odooUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  return '$normalizedUrl|${database.trim()}|${user.uid}';
}

@riverpod
Stream<List<LocalExpense>> expenses(Ref ref) async* {
  final accountScope = await ref.watch(currentAccountScopeProvider.future);
  if (accountScope == null) {
    yield const [];
    return;
  }

  final repository = ref.watch(localExpensesRepositoryProvider);
  yield* repository.watchExpenses(accountScope);
}

@riverpod
Future<String> receiptPath(Ref ref, String relativePath) {
  return ref
      .watch(localExpensesRepositoryProvider)
      .resolveReceiptPath(relativePath);
}

class ExpenseSyncState {
  final bool isSyncing;
  final int syncedCount;
  final int failedCount;
  final int remoteCount;
  final String message;

  const ExpenseSyncState({
    this.isSyncing = false,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.remoteCount = 0,
    this.message = '',
  });
}

@Riverpod(keepAlive: true)
class ExpenseSyncNotifier extends _$ExpenseSyncNotifier {
  @override
  ExpenseSyncState build() => const ExpenseSyncState();

  Future<bool> syncExpense(LocalExpense expense) async {
    if (state.isSyncing) return false;
    final connection = await _loadConnection();
    if (connection == null || !ref.mounted) return false;

    state = const ExpenseSyncState(isSyncing: true);
    final result = await _service.syncExpense(
      expense: expense,
      odooUrl: connection.odooUrl,
      database: connection.database,
      sessionId: connection.sessionId,
    );
    if (!ref.mounted) return result.isSuccess;

    state = ExpenseSyncState(
      syncedCount: result.isSuccess ? 1 : 0,
      failedCount: result.isSuccess ? 0 : 1,
      message: result.isSuccess
          ? 'Gasto sincronizado con Odoo.'
          : result.errorMessage ?? 'No se pudo sincronizar el gasto.',
    );
    return result.isSuccess;
  }

  Future<void> syncAll() async {
    if (state.isSyncing) return;
    final connection = await _loadConnection();
    if (connection == null || !ref.mounted) return;
    final accountScope = await ref.read(currentAccountScopeProvider.future);
    if (accountScope == null || !ref.mounted) {
      state = const ExpenseSyncState(
        message: 'No se encontró el perfil local del usuario.',
      );
      return;
    }

    state = const ExpenseSyncState(isSyncing: true);
    late final List<LocalExpense> expenses;
    try {
      expenses = await ref
          .read(localExpensesRepositoryProvider)
          .getUnsyncedExpenses(accountScope);
    } catch (_) {
      if (ref.mounted) {
        state = const ExpenseSyncState(
          failedCount: 1,
          message: 'No se pudieron leer los gastos pendientes.',
        );
      }
      return;
    }
    if (!ref.mounted) return;
    var synced = 0;
    var failed = 0;
    var remoteCount = 0;
    String? lastError;
    for (final expense in expenses) {
      final result = await _service.syncExpense(
        expense: expense,
        odooUrl: connection.odooUrl,
        database: connection.database,
        sessionId: connection.sessionId,
      );
      if (result.isSuccess) {
        synced++;
      } else {
        failed++;
        lastError = result.errorMessage;
      }
    }
    if (!ref.mounted) return;

    try {
      final remoteExpenses = await ref
          .read(remoteExpensesRepositoryProvider)
          .getExpenses(
            odooUrl: connection.odooUrl,
            database: connection.database,
            sessionId: connection.sessionId,
            userId: connection.userId,
          );
      await ref
          .read(localExpensesRepositoryProvider)
          .cacheRemoteExpenses(
            expenses: remoteExpenses,
            accountScope: accountScope,
          );
      remoteCount = remoteExpenses.length;
    } on CustomError catch (error) {
      failed++;
      lastError = error.message;
    } catch (_) {
      failed++;
      lastError = 'No se pudieron descargar los gastos desde Odoo.';
    }
    if (!ref.mounted) return;

    state = ExpenseSyncState(
      syncedCount: synced,
      failedCount: failed,
      remoteCount: remoteCount,
      message: failed == 0
          ? 'Listado actualizado: $remoteCount gasto${remoteCount == 1 ? '' : 's'} de Odoo.'
          : '$synced enviado${synced == 1 ? '' : 's'} y $failed operación${failed == 1 ? '' : 'es'} con error. '
                '${lastError ?? ''}',
    );
  }

  ExpenseSyncService get _service => ExpenseSyncService(
    ref.read(localExpensesRepositoryProvider),
    ref.read(remoteExpensesRepositoryProvider),
  );

  Future<_OdooSyncConnection?> _loadConnection() async {
    final authNotifier = ref.read(authProvider.notifier);
    final hasOnlineSession = await authNotifier.ensureOnlineSession();
    final authState = ref.read(authProvider);
    final user = authState.user;
    if (!hasOnlineSession || user == null || user.sessionId.trim().isEmpty) {
      if (ref.mounted) {
        state = ExpenseSyncState(
          message: authState.errorMessage.isNotEmpty
              ? authState.errorMessage
              : 'La sesión de Odoo no está activa. Verifica las credenciales y la conexión.',
        );
      }
      return null;
    }
    final userId = int.tryParse(user.uid);
    if (userId == null || userId <= 0) {
      if (ref.mounted) {
        state = const ExpenseSyncState(
          message: 'Odoo no devolvió un identificador de usuario válido.',
        );
      }
      return null;
    }

    final storage = KeyValueStorageServiceImpl();
    final odooUrl = await storage.getValue<String>('odooUrl');
    final database = await storage.getValue<String>('odooDatabase');
    if (odooUrl == null ||
        odooUrl.trim().isEmpty ||
        database == null ||
        database.trim().isEmpty) {
      if (ref.mounted) {
        state = const ExpenseSyncState(
          message: 'Faltan los datos de conexión con Odoo.',
        );
      }
      return null;
    }

    return _OdooSyncConnection(
      odooUrl: odooUrl.trim(),
      database: database.trim(),
      sessionId: user.sessionId,
      userId: userId,
    );
  }
}

class _OdooSyncConnection {
  final String odooUrl;
  final String database;
  final String sessionId;
  final int userId;

  const _OdooSyncConnection({
    required this.odooUrl,
    required this.database,
    required this.sessionId,
    required this.userId,
  });
}
