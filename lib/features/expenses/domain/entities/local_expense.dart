import 'package:oh_expenses_app/features/expenses/domain/entities/expense_sync_status.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/ocr_expense_result.dart';

class LocalExpense {
  final String id;
  final String accountScope;
  final int? remoteId;
  final String ruc;
  final String businessName;
  final String documentType;
  final String documentNumber;
  final int? productId;
  final String? productName;
  final String date;
  final int subtotalCents;
  final int igvCents;
  final int totalCents;
  final ExpenseTaxTreatment taxTreatment;
  final int? taxId;
  final String? taxName;
  final double taxRatePercentage;
  final String receiptRelativePath;
  final ExpenseSyncStatus syncStatus;
  final String? lastSyncError;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LocalExpense({
    required this.id,
    required this.accountScope,
    required this.remoteId,
    required this.ruc,
    required this.businessName,
    required this.documentType,
    required this.documentNumber,
    this.productId,
    this.productName,
    required this.date,
    required this.subtotalCents,
    required this.igvCents,
    required this.totalCents,
    required this.taxTreatment,
    required this.taxId,
    required this.taxName,
    required this.taxRatePercentage,
    required this.receiptRelativePath,
    required this.syncStatus,
    required this.lastSyncError,
    required this.createdAt,
    required this.updatedAt,
  });

  double get subtotal => subtotalCents / 100;
  double get igv => igvCents / 100;
  double get total => totalCents / 100;
  bool get isRemoteOnly => remoteId != null && receiptRelativePath.isEmpty;

  String get displayName {
    if (businessName.trim().isNotEmpty) return businessName.trim();
    if (documentNumber.trim().isNotEmpty) {
      return '${documentType.trim()} ${documentNumber.trim()}'.trim();
    }
    return documentType.trim().isEmpty ? 'Gasto local' : documentType.trim();
  }
}
