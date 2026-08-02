import 'package:oh_expenses_app/features/expenses/domain/domain.dart';

class ExpenseMapper {
  static Expense odooJsonToEntity(Map<String, dynamic> json) {
    return Expense(
      id: _intValue(json['id']),
      name: _stringValue(json['name'], fallback: 'Gasto sin título'),
      employeeName: _many2OneName(json['employee_id']),
      date: _stringValue(json['date']),
      state: _stringValue(json['state'], fallback: 'draft'),
      totalAmount: _doubleValue(
        json['total_amount_currency'] ?? json['total_amount'],
      ),
      currency: _many2OneName(json['currency_id'], fallback: 'PEN'),
      category: _many2OneName(json['product_id']),
      description: _stringValue(json['description']),
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null || value == false) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String _many2OneName(dynamic value, {String fallback = ''}) {
    if (value is List && value.length > 1) {
      return _stringValue(value[1], fallback: fallback);
    }

    return _stringValue(value, fallback: fallback);
  }
}

class ExpenseAttachmentMapper {
  static ExpenseAttachment odooJsonToEntity(Map<String, dynamic> json) {
    return ExpenseAttachment(
      id: ExpenseMapper._intValue(json['id']),
      name: ExpenseMapper._stringValue(json['name'], fallback: 'Adjunto'),
      mimetype: ExpenseMapper._stringValue(json['mimetype']),
    );
  }
}
