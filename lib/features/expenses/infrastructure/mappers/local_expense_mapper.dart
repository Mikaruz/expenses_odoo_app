import 'package:drift/drift.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/database/expenses_database.dart';

class LocalExpenseMapper {
  static LocalExpense fromRow(LocalExpenseRow row) {
    return LocalExpense(
      id: row.id,
      accountScope: row.accountScope,
      remoteId: row.remoteId,
      ruc: row.ruc,
      businessName: row.businessName,
      documentType: row.documentType,
      documentNumber: row.documentNumber,
      date: row.expenseDate,
      subtotalCents: row.subtotalCents,
      igvCents: row.igvCents,
      totalCents: row.totalCents,
      taxTreatment: ExpenseTaxTreatment.values.firstWhere(
        (treatment) => treatment.name == row.taxTreatment,
        orElse: () => ExpenseTaxTreatment.unknown,
      ),
      taxId: row.taxId,
      taxName: row.taxName,
      taxRatePercentage: row.taxRatePercentage,
      receiptRelativePath: row.receiptRelativePath,
      syncStatus: ExpenseSyncStatus.fromStorage(row.syncStatus),
      lastSyncError: row.lastSyncError,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static LocalExpensesCompanion toCompanion(LocalExpense expense) {
    return LocalExpensesCompanion.insert(
      id: expense.id,
      accountScope: expense.accountScope,
      remoteId: Value(expense.remoteId),
      ruc: Value(expense.ruc),
      businessName: Value(expense.businessName),
      documentType: Value(expense.documentType),
      documentNumber: Value(expense.documentNumber),
      expenseDate: Value(expense.date),
      subtotalCents: expense.subtotalCents,
      igvCents: expense.igvCents,
      totalCents: expense.totalCents,
      taxTreatment: expense.taxTreatment.name,
      taxId: Value(expense.taxId),
      taxName: Value(expense.taxName),
      taxRatePercentage: expense.taxRatePercentage,
      receiptRelativePath: expense.receiptRelativePath,
      syncStatus: expense.syncStatus.name,
      lastSyncError: Value(expense.lastSyncError),
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }
}
