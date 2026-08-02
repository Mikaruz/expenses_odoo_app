import 'package:oh_expenses_app/features/auth/auth.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/infrastructure.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expenses_provider.g.dart';

class ExpensesState {
  final bool isLoading;
  final bool hasLoaded;
  final List<Expense> expenses;
  final String errorMessage;

  const ExpensesState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.expenses = const [],
    this.errorMessage = '',
  });

  ExpensesState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    List<Expense>? expenses,
    String? errorMessage,
  }) {
    return ExpensesState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      expenses: expenses ?? this.expenses,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class ExpensesNotifier extends _$ExpensesNotifier {
  late final _expenseRepository = ExpensesRepositoryImpl(
    ExpensesDatasourceImpl(),
  );
  late final KeyValueStorageService _storage;

  @override
  ExpensesState build() {
    _storage = KeyValueStorageServiceImpl();
    return const ExpensesState();
  }

  Future<void> loadExpenses() async {
    if (state.isLoading) return;

    final authState = ref.read(authProvider);
    final user = authState.user;

    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Inicia sesión para consultar tus gastos.',
      );
      return;
    }

    final userId = int.tryParse(user.uid);
    final odooUrl = await _storage.getValue<String>('odooUrl');
    final database = await _storage.getValue<String>('odooDatabase');

    if (userId == null || odooUrl == null || database == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Faltan datos de conexión para consultar Odoo.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final expenses = await _expenseRepository.getExpenses(
        odooUrl: odooUrl,
        database: database,
        sessionId: user.sessionId,
        userId: userId,
      );

      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        expenses: expenses,
      );
    } on CustomError catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: 'Error inesperado consultando gastos.',
      );
    }
  }
}
