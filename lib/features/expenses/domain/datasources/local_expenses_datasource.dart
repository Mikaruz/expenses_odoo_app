import 'package:oh_expenses_app/features/expenses/domain/entities/local_expense.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/expense_sync_status.dart';

abstract class LocalExpensesDatasource {
  Stream<List<LocalExpense>> watchExpenses(String accountScope);
  Future<LocalExpense?> getExpense(String id, String accountScope);
  Future<List<LocalExpense>> getUnsyncedExpenses(String accountScope);
  Future<void> insertExpense(LocalExpense expense);
  Future<void> updateExpense(LocalExpense expense);
  Future<void> reconcileRemoteExpenses(
    String accountScope,
    List<LocalExpense> expenses,
  );
  Future<void> updateSyncState({
    required String id,
    required String accountScope,
    required int? remoteId,
    required ExpenseSyncStatus status,
    required String? errorMessage,
  });
}
