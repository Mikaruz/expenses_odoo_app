import 'package:oh_expenses_app/features/expenses/domain/entities/ocr_expense_result.dart';

class ExpenseDraft {
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

  const ExpenseDraft({
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
  });
}
