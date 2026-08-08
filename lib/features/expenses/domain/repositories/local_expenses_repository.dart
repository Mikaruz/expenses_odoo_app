import 'package:oh_expenses_app/features/expenses/domain/entities/expense_draft.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/expense.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/expense_sync_status.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/local_expense.dart';

abstract class LocalExpensesRepository {
  Stream<List<LocalExpense>> watchExpenses(String accountScope);

  Future<LocalExpense?> getExpense(String id, String accountScope);

  Future<List<LocalExpense>> getUnsyncedExpenses(String accountScope);

  Future<LocalExpense> saveExpense({
    required ExpenseDraft draft,
    required String sourceImagePath,
    required String accountScope,
  });

  Future<LocalExpense> updateExpense({
    required LocalExpense expense,
    required ExpenseDraft draft,
  });

  Future<void> cacheRemoteExpenses({
    required List<Expense> expenses,
    required String accountScope,
  });

  Future<String> resolveReceiptPath(String relativePath);

  Future<void> updateSyncState({
    required String id,
    required String accountScope,
    required int? remoteId,
    required ExpenseSyncStatus status,
    required String? errorMessage,
  });
}
