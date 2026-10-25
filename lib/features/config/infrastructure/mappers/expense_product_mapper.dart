import 'package:oh_expenses_app/features/config/domain/entities/expense_product.dart';

class ExpenseProductMapper {
  static ExpenseProduct odooJsonToEntity(Map<String, dynamic> json) {
    return ExpenseProduct(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: ExpenseProduct.normalizeName(
        _stringValue(
          json['display_name'] ?? json['name'],
          fallback: 'Categoría sin nombre',
        ),
      ),
      defaultCode: _stringValue(json['default_code']),
    );
  }

  static String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null || value == false) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }
}
