import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

class ExpenseSyncAttempt {
  final bool isSuccess;
  final int? remoteId;
  final String? errorMessage;

  const ExpenseSyncAttempt.success(this.remoteId)
    : isSuccess = true,
      errorMessage = null;

  const ExpenseSyncAttempt.failure(this.errorMessage)
    : isSuccess = false,
      remoteId = null;
}

class ExpenseSyncService {
  final LocalExpensesRepository _localRepository;
  final ExpensesRepository _remoteRepository;

  const ExpenseSyncService(this._localRepository, this._remoteRepository);

  Future<ExpenseSyncAttempt> syncExpense({
    required LocalExpense expense,
    required String odooUrl,
    required String database,
    required String sessionId,
  }) async {
    if (expense.syncStatus == ExpenseSyncStatus.synced &&
        expense.remoteId != null) {
      return ExpenseSyncAttempt.success(expense.remoteId);
    }

    try {
      final int remoteId;
      if (expense.remoteId == null) {
        remoteId = await _remoteRepository.createExpense(
          odooUrl: odooUrl,
          database: database,
          sessionId: sessionId,
          expense: expense,
        );
      } else {
        await _remoteRepository.updateExpense(
          odooUrl: odooUrl,
          database: database,
          sessionId: sessionId,
          expense: expense,
        );
        remoteId = expense.remoteId!;
      }
      await _localRepository.updateSyncState(
        id: expense.id,
        accountScope: expense.accountScope,
        remoteId: remoteId,
        status: ExpenseSyncStatus.synced,
        errorMessage: null,
      );
      Logger.success(
        '[ExpenseSync][${expense.id}] sincronizado con Odoo #$remoteId',
      );
      return ExpenseSyncAttempt.success(remoteId);
    } on CustomError catch (error) {
      Logger.error(
        '[ExpenseSync][${expense.id}] Odoo rechazó el gasto: ${error.message}',
      );
      await _markAsFailed(expense, error.message);
      return ExpenseSyncAttempt.failure(error.message);
    } catch (error) {
      const message = 'No se pudo sincronizar el gasto con Odoo.';
      Logger.error('[ExpenseSync][${expense.id}] $error');
      await _markAsFailed(expense, message);
      return const ExpenseSyncAttempt.failure(message);
    }
  }

  Future<void> _markAsFailed(LocalExpense expense, String message) async {
    try {
      await _localRepository.updateSyncState(
        id: expense.id,
        accountScope: expense.accountScope,
        remoteId: expense.remoteId,
        status: ExpenseSyncStatus.error,
        errorMessage: message,
      );
    } catch (error) {
      Logger.error(
        '[ExpenseSync][${expense.id}] no se pudo guardar el error: $error',
      );
    }
  }
}
