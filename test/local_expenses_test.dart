import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/database/expenses_database.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/datasources/drift_local_expenses_datasource.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/repositories/local_expenses_repository_impl.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/services/expense_sync_service.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

void main() {
  group('DriftLocalExpensesDatasource', () {
    late ExpensesDatabase database;
    late DriftLocalExpensesDatasource datasource;

    setUp(() {
      database = ExpensesDatabase.forTesting(NativeDatabase.memory());
      datasource = DriftLocalExpensesDatasource(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('persiste montos y estado sin perder centimos', () async {
      final expense = _expense(id: 'expense-1', accountScope: 'account-a');

      await datasource.insertExpense(expense);
      final stored = await datasource.getExpense('expense-1', 'account-a');

      expect(stored, isNotNull);
      expect(stored?.subtotalCents, 8475);
      expect(stored?.igvCents, 1525);
      expect(stored?.totalCents, 10000);
      expect(stored?.total, 100.00);
      expect(stored?.syncStatus, ExpenseSyncStatus.pending);
      expect(stored?.receiptRelativePath, 'receipts/expense-1.jpg');
    });

    test('aísla los gastos por cuenta local', () async {
      await datasource.insertExpense(
        _expense(id: 'expense-a', accountScope: 'account-a'),
      );
      await datasource.insertExpense(
        _expense(id: 'expense-b', accountScope: 'account-b'),
      );

      final accountA = await datasource.watchExpenses('account-a').first;
      final accountB = await datasource.watchExpenses('account-b').first;

      expect(accountA.map((expense) => expense.id), ['expense-a']);
      expect(accountB.map((expense) => expense.id), ['expense-b']);
    });

    test('actualiza el estado y excluye los gastos sincronizados', () async {
      await datasource.insertExpense(
        _expense(id: 'expense-1', accountScope: 'account-a'),
      );

      await datasource.updateSyncState(
        id: 'expense-1',
        accountScope: 'account-a',
        remoteId: 42,
        status: ExpenseSyncStatus.synced,
        errorMessage: null,
      );

      final stored = await datasource.getExpense('expense-1', 'account-a');
      final unsynced = await datasource.getUnsyncedExpenses('account-a');
      expect(stored?.remoteId, 42);
      expect(stored?.syncStatus, ExpenseSyncStatus.synced);
      expect(unsynced, isEmpty);
    });
  });

  group('LocalExpensesRepositoryImpl', () {
    test('guarda un gasto nuevo como pendiente', () async {
      final database = ExpensesDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final storage = _FakeReceiptStorage();
      final repository = LocalExpensesRepositoryImpl(
        DriftLocalExpensesDatasource(database),
        storage,
      );

      final expense = await repository.saveExpense(
        draft: _draft,
        sourceImagePath: 'temporary/receipt.jpg',
        accountScope: 'account-a',
      );

      expect(expense.syncStatus, ExpenseSyncStatus.pending);
      expect(expense.remoteId, isNull);
      expect(expense.receiptRelativePath, contains(expense.id));
      expect(storage.sourcePath, 'temporary/receipt.jpg');
      expect(await repository.getExpense(expense.id, 'account-a'), isNotNull);
    });

    test('elimina la copia si falla la insercion local', () async {
      final storage = _FakeReceiptStorage();
      final repository = LocalExpensesRepositoryImpl(
        _FailingLocalExpensesDatasource(),
        storage,
      );

      await expectLater(
        repository.saveExpense(
          draft: _draft,
          sourceImagePath: 'temporary/receipt.jpg',
          accountScope: 'account-a',
        ),
        throwsA(isA<CustomError>()),
      );

      expect(storage.deletedPath, isNotNull);
    });

    test(
      'combina gastos remotos sin duplicar los creados localmente',
      () async {
        final database = ExpensesDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);
        final datasource = DriftLocalExpensesDatasource(database);
        final repository = LocalExpensesRepositoryImpl(
          datasource,
          _FakeReceiptStorage(),
        );
        await datasource.insertExpense(
          _expense(
            id: 'local-synced',
            accountScope: 'account-a',
            remoteId: 7,
            syncStatus: ExpenseSyncStatus.synced,
          ),
        );

        await repository.cacheRemoteExpenses(
          accountScope: 'account-a',
          expenses: const [
            Expense(
              id: 7,
              name: 'Gasto creado en la app',
              employeeName: 'Usuario',
              date: '2026-08-01',
              state: 'draft',
              totalAmount: 100,
              currency: 'PEN',
              category: 'Varios',
              description: '',
            ),
            Expense(
              id: 8,
              name: 'Gasto existente en Odoo',
              employeeName: 'Usuario',
              date: '2026-08-02',
              state: 'reported',
              totalAmount: 25.50,
              currency: 'PEN',
              category: 'Alimentación',
              description: '',
            ),
          ],
        );

        final expenses = await repository.watchExpenses('account-a').first;
        expect(expenses, hasLength(2));
        expect(
          expenses.where((expense) => expense.remoteId == 7).single.id,
          'local-synced',
        );
        final imported = expenses
            .where((expense) => expense.remoteId == 8)
            .single;
        expect(imported.isRemoteOnly, isTrue);
        expect(imported.totalCents, 2550);
        expect(imported.syncStatus, ExpenseSyncStatus.synced);

        await repository.cacheRemoteExpenses(
          accountScope: 'account-a',
          expenses: const [
            Expense(
              id: 7,
              name: 'Gasto creado en la app',
              employeeName: 'Usuario',
              date: '2026-08-01',
              state: 'draft',
              totalAmount: 100,
              currency: 'PEN',
              category: 'Varios',
              description: '',
            ),
          ],
        );

        final reconciled = await repository.watchExpenses('account-a').first;
        expect(reconciled.map((expense) => expense.remoteId), [7]);
      },
    );

    test('edita un gasto y lo vuelve a dejar pendiente', () async {
      final database = ExpensesDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final datasource = DriftLocalExpensesDatasource(database);
      final repository = LocalExpensesRepositoryImpl(
        datasource,
        _FakeReceiptStorage(),
      );
      final original = _expense(
        id: 'expense-edit',
        accountScope: 'account-a',
        remoteId: 21,
        syncStatus: ExpenseSyncStatus.synced,
      );
      await datasource.insertExpense(original);
      const editedDraft = ExpenseDraft(
        ruc: '20100070970',
        businessName: 'Comercio editado',
        documentType: 'FACTURA',
        documentNumber: 'F001-999',
        date: '03/08/2026',
        subtotalCents: 10000,
        igvCents: 1800,
        totalCents: 11800,
        taxTreatment: ExpenseTaxTreatment.taxable,
        taxId: 7,
        taxName: 'IGV 18%',
        taxRatePercentage: 18,
      );

      final updated = await repository.updateExpense(
        expense: original,
        draft: editedDraft,
      );

      expect(updated.businessName, 'Comercio editado');
      expect(updated.totalCents, 11800);
      expect(updated.remoteId, 21);
      expect(updated.syncStatus, ExpenseSyncStatus.pending);
      expect(updated.receiptRelativePath, original.receiptRelativePath);
    });
  });

  group('ExpenseSyncService', () {
    test('guarda el id remoto y marca el gasto como sincronizado', () async {
      final database = ExpensesDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = LocalExpensesRepositoryImpl(
        DriftLocalExpensesDatasource(database),
        _FakeReceiptStorage(),
      );
      final expense = _expense(id: 'expense-sync', accountScope: 'account-a');
      await DriftLocalExpensesDatasource(database).insertExpense(expense);
      final service = ExpenseSyncService(
        repository,
        _FakeRemoteExpensesRepository(remoteId: 77),
      );

      final result = await service.syncExpense(
        expense: expense,
        odooUrl: 'https://odoo.example.com',
        database: 'demo',
        sessionId: 'session',
      );
      final stored = await repository.getExpense('expense-sync', 'account-a');

      expect(result.isSuccess, isTrue);
      expect(stored?.remoteId, 77);
      expect(stored?.syncStatus, ExpenseSyncStatus.synced);
      expect(stored?.lastSyncError, isNull);
    });

    test('conserva el gasto y registra el error de Odoo', () async {
      final database = ExpensesDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = LocalExpensesRepositoryImpl(
        DriftLocalExpensesDatasource(database),
        _FakeReceiptStorage(),
      );
      final expense = _expense(id: 'expense-error', accountScope: 'account-a');
      await DriftLocalExpensesDatasource(database).insertExpense(expense);
      final service = ExpenseSyncService(
        repository,
        _FakeRemoteExpensesRepository(error: 'Categoría requerida'),
      );

      final result = await service.syncExpense(
        expense: expense,
        odooUrl: 'https://odoo.example.com',
        database: 'demo',
        sessionId: 'session',
      );
      final stored = await repository.getExpense('expense-error', 'account-a');

      expect(result.isSuccess, isFalse);
      expect(stored?.remoteId, isNull);
      expect(stored?.syncStatus, ExpenseSyncStatus.error);
      expect(stored?.lastSyncError, 'Categoría requerida');
    });

    test('actualiza el registro remoto cuando ya tiene id de Odoo', () async {
      final database = ExpensesDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = LocalExpensesRepositoryImpl(
        DriftLocalExpensesDatasource(database),
        _FakeReceiptStorage(),
      );
      final expense = _expense(
        id: 'expense-update',
        accountScope: 'account-a',
        remoteId: 90,
      );
      await DriftLocalExpensesDatasource(database).insertExpense(expense);
      final remoteRepository = _FakeRemoteExpensesRepository();
      final service = ExpenseSyncService(repository, remoteRepository);

      final result = await service.syncExpense(
        expense: expense,
        odooUrl: 'https://odoo.example.com',
        database: 'demo',
        sessionId: 'session',
      );

      expect(result.isSuccess, isTrue);
      expect(result.remoteId, 90);
      expect(remoteRepository.updateCalls, 1);
    });
  });
}

const _draft = ExpenseDraft(
  ruc: '20100070970',
  businessName: 'Comercio local',
  documentType: 'FACTURA',
  documentNumber: 'F001-123',
  date: '02/08/2026',
  subtotalCents: 8475,
  igvCents: 1525,
  totalCents: 10000,
  taxTreatment: ExpenseTaxTreatment.taxable,
  taxId: 7,
  taxName: 'IGV 18%',
  taxRatePercentage: 18,
);

LocalExpense _expense({
  required String id,
  required String accountScope,
  int? remoteId,
  ExpenseSyncStatus syncStatus = ExpenseSyncStatus.pending,
}) {
  final now = DateTime.utc(2026, 8, 2);
  return LocalExpense(
    id: id,
    accountScope: accountScope,
    remoteId: remoteId,
    ruc: _draft.ruc,
    businessName: _draft.businessName,
    documentType: _draft.documentType,
    documentNumber: _draft.documentNumber,
    date: _draft.date,
    subtotalCents: _draft.subtotalCents,
    igvCents: _draft.igvCents,
    totalCents: _draft.totalCents,
    taxTreatment: _draft.taxTreatment,
    taxId: _draft.taxId,
    taxName: _draft.taxName,
    taxRatePercentage: _draft.taxRatePercentage,
    receiptRelativePath: 'receipts/$id.jpg',
    syncStatus: syncStatus,
    lastSyncError: null,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeReceiptStorage implements ReceiptStorageDatasource {
  String? sourcePath;
  String? deletedPath;

  @override
  Future<String> copyReceipt({
    required String sourcePath,
    required String receiptId,
  }) async {
    this.sourcePath = sourcePath;
    return 'receipts/$receiptId.jpg';
  }

  @override
  Future<void> deleteReceipt(String relativePath) async {
    deletedPath = relativePath;
  }

  @override
  Future<String> resolvePath(String relativePath) async {
    return 'support/$relativePath';
  }
}

class _FailingLocalExpensesDatasource implements LocalExpensesDatasource {
  @override
  Future<LocalExpense?> getExpense(String id, String accountScope) async =>
      null;

  @override
  Future<List<LocalExpense>> getUnsyncedExpenses(String accountScope) async =>
      const [];

  @override
  Future<void> insertExpense(LocalExpense expense) {
    throw StateError('Database unavailable');
  }

  @override
  Future<void> updateExpense(LocalExpense expense) async {}

  @override
  Future<void> reconcileRemoteExpenses(
    String accountScope,
    List<LocalExpense> expenses,
  ) async {}

  @override
  Stream<List<LocalExpense>> watchExpenses(String accountScope) {
    return const Stream.empty();
  }

  @override
  Future<void> updateSyncState({
    required String id,
    required String accountScope,
    required int? remoteId,
    required ExpenseSyncStatus status,
    required String? errorMessage,
  }) async {}
}

class _FakeRemoteExpensesRepository implements ExpensesRepository {
  final int remoteId;
  final String? error;
  int updateCalls = 0;

  _FakeRemoteExpensesRepository({this.remoteId = 1, this.error});

  @override
  Future<int> createExpense({
    required String odooUrl,
    required String database,
    required String sessionId,
    required LocalExpense expense,
  }) async {
    if (error != null) throw CustomError(error!);
    return remoteId;
  }

  @override
  Future<List<ExpenseAttachment>> getExpenseAttachments({
    required String odooUrl,
    required String sessionId,
    required int expenseId,
  }) async => const [];

  @override
  Future<List<Expense>> getExpenses({
    required String odooUrl,
    required String database,
    required String sessionId,
    required int userId,
  }) async => const [];

  @override
  Future<String?> pickImage(ImageSource source) async => null;

  @override
  Future<String?> processImagePath(String imagePath) async => null;

  @override
  Future<void> updateExpense({
    required String odooUrl,
    required String database,
    required String sessionId,
    required LocalExpense expense,
  }) async {
    if (error != null) throw CustomError(error!);
    updateCalls++;
  }
}
