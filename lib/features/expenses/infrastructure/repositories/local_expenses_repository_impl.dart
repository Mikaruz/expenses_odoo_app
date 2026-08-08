import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:uuid/uuid.dart';

class LocalExpensesRepositoryImpl extends LocalExpensesRepository {
  final LocalExpensesDatasource _localDatasource;
  final ReceiptStorageDatasource _receiptStorage;
  final Uuid _uuid;

  LocalExpensesRepositoryImpl(
    this._localDatasource,
    this._receiptStorage, {
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  @override
  Stream<List<LocalExpense>> watchExpenses(String accountScope) {
    return _localDatasource.watchExpenses(accountScope);
  }

  @override
  Future<LocalExpense?> getExpense(String id, String accountScope) {
    return _localDatasource.getExpense(id, accountScope);
  }

  @override
  Future<List<LocalExpense>> getUnsyncedExpenses(String accountScope) {
    return _localDatasource.getUnsyncedExpenses(accountScope);
  }

  @override
  Future<LocalExpense> saveExpense({
    required ExpenseDraft draft,
    required String sourceImagePath,
    required String accountScope,
  }) async {
    final localId = _uuid.v4();
    Logger.info('[LocalExpense][$localId] iniciando guardado local');

    String? receiptPath;
    try {
      receiptPath = await _receiptStorage.copyReceipt(
        sourcePath: sourceImagePath,
        receiptId: localId,
      );
      final now = DateTime.now().toUtc();
      final expense = LocalExpense(
        id: localId,
        accountScope: accountScope,
        remoteId: null,
        ruc: draft.ruc,
        businessName: draft.businessName,
        documentType: draft.documentType,
        documentNumber: draft.documentNumber,
        date: draft.date,
        subtotalCents: draft.subtotalCents,
        igvCents: draft.igvCents,
        totalCents: draft.totalCents,
        taxTreatment: draft.taxTreatment,
        taxId: draft.taxId,
        taxName: draft.taxName,
        taxRatePercentage: draft.taxRatePercentage,
        receiptRelativePath: receiptPath,
        syncStatus: ExpenseSyncStatus.pending,
        lastSyncError: null,
        createdAt: now,
        updatedAt: now,
      );

      await _localDatasource.insertExpense(expense);
      Logger.success('[LocalExpense][$localId] guardado con estado pending');
      return expense;
    } on CustomError {
      if (receiptPath != null) await _receiptStorage.deleteReceipt(receiptPath);
      rethrow;
    } catch (error) {
      if (receiptPath != null) await _receiptStorage.deleteReceipt(receiptPath);
      Logger.error('[LocalExpense][$localId] error de persistencia: $error');
      throw CustomError('No se pudo guardar el gasto localmente.');
    }
  }

  @override
  Future<LocalExpense> updateExpense({
    required LocalExpense expense,
    required ExpenseDraft draft,
  }) async {
    final updated = LocalExpense(
      id: expense.id,
      accountScope: expense.accountScope,
      remoteId: expense.remoteId,
      ruc: draft.ruc,
      businessName: draft.businessName,
      documentType: draft.documentType,
      documentNumber: draft.documentNumber,
      date: draft.date,
      subtotalCents: draft.subtotalCents,
      igvCents: draft.igvCents,
      totalCents: draft.totalCents,
      taxTreatment: draft.taxTreatment,
      taxId: draft.taxId,
      taxName: draft.taxName,
      taxRatePercentage: draft.taxRatePercentage,
      receiptRelativePath: expense.receiptRelativePath,
      syncStatus: ExpenseSyncStatus.pending,
      lastSyncError: null,
      createdAt: expense.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    try {
      await _localDatasource.updateExpense(updated);
      return updated;
    } catch (error) {
      Logger.error('[LocalExpense][${expense.id}] error al editar: $error');
      throw CustomError('No se pudo actualizar el gasto localmente.');
    }
  }

  @override
  Future<void> cacheRemoteExpenses({
    required List<Expense> expenses,
    required String accountScope,
  }) {
    final now = DateTime.now().toUtc();
    final cachedExpenses = expenses.map((expense) {
      final expenseDate = DateTime.tryParse(expense.date)?.toUtc() ?? now;
      final totalCents = (expense.totalAmount * 100).round();
      return LocalExpense(
        id: 'odoo:${Uri.encodeComponent(accountScope)}:${expense.id}',
        accountScope: accountScope,
        remoteId: expense.id,
        ruc: '',
        businessName: expense.name,
        documentType: expense.category,
        documentNumber: '',
        date: expense.date,
        subtotalCents: totalCents,
        igvCents: 0,
        totalCents: totalCents,
        taxTreatment: ExpenseTaxTreatment.unknown,
        taxId: null,
        taxName: null,
        taxRatePercentage: 0,
        receiptRelativePath: '',
        syncStatus: ExpenseSyncStatus.synced,
        lastSyncError: null,
        createdAt: expenseDate,
        updatedAt: now,
      );
    }).toList();
    return _localDatasource.reconcileRemoteExpenses(
      accountScope,
      cachedExpenses,
    );
  }

  @override
  Future<String> resolveReceiptPath(String relativePath) {
    return _receiptStorage.resolvePath(relativePath);
  }

  @override
  Future<void> updateSyncState({
    required String id,
    required String accountScope,
    required int? remoteId,
    required ExpenseSyncStatus status,
    required String? errorMessage,
  }) {
    return _localDatasource.updateSyncState(
      id: id,
      accountScope: accountScope,
      remoteId: remoteId,
      status: status,
      errorMessage: errorMessage,
    );
  }
}
