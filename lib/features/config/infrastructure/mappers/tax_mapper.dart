import 'package:oh_expenses_app/features/config/domain/entities/tax.dart';

class TaxMapper {
  static ExpenseTax odooJsonToEntity(Map<String, dynamic> json) {
    final amount = json['amount'];
    final ratePercentage = amount is num ? amount.toDouble() : 0.0;

    return ExpenseTax(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      ratePercentage: ratePercentage,
      amountType: (json['amount_type'] ?? json['type'] ?? '').toString(),
      taxTypeUse: (json['type_tax_use'] ?? '').toString(),
    );
  }
}
