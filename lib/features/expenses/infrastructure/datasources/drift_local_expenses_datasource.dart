import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/database/expenses_database.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/mappers/local_expense_mapper.dart';

class DriftLocalExpensesDatasource extends LocalExpensesDatasource {
  final ExpensesDatabase _database;

  DriftLocalExpensesDatasource(this._database);

  @override
  Stream<List<LocalExpense>> watchExpenses(String accountScope) {
    return _database
        .watchExpenses(accountScope)
        .map((rows) => rows.map(LocalExpenseMapper.fromRow).toList());
  }

  @override
  Future<LocalExpense?> getExpense(String id, String accountScope) async {
    final row = await _database.getExpense(id, accountScope);
    return row == null ? null : LocalExpenseMapper.fromRow(row);
  }

  @override
  Future<List<LocalExpense>> getUnsyncedExpenses(String accountScope) async {
    final rows = await _database.getUnsyncedExpenses(accountScope);
    return rows.map(LocalExpenseMapper.fromRow).toList();
  }

  @override
  Future<void> insertExpense(LocalExpense expense) {
    return _database.insertLocalExpense(
      LocalExpenseMapper.toCompanion(expense),
    );
  }

  @override
  Future<void> updateExpense(LocalExpense expense) {
    return _database.updateLocalExpense(
      LocalExpenseMapper.toCompanion(expense),
    );
  }

  @override
  Future<void> reconcileRemoteExpenses(
    String accountScope,
    List<LocalExpense> expenses,
  ) {
    return _database.reconcileRemoteExpenses(
      accountScope: accountScope,
      expenses: expenses.map(LocalExpenseMapper.toCompanion).toList(),
    );
  }

  @override
  Future<void> updateSyncState({
    required String id,
    required String accountScope,
    required int? remoteId,
    required ExpenseSyncStatus status,
    required String? errorMessage,
  }) {
    return _database.updateSyncState(
      id: id,
      accountScope: accountScope,
      remoteId: remoteId,
      status: status.name,
      errorMessage: errorMessage,
    );
  }
}
