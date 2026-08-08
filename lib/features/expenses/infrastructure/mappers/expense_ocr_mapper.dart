import 'package:oh_expenses_app/features/expenses/domain/entities/ocr_expense_result.dart';

class ExpenseOcrMapper {
  static OcrExpenseResult fromApiPayload(Map<String, dynamic> payload) {
    final fields = <String, Map<String, dynamic>>{};
    final rawFields = payload['fields'];
    if (rawFields is List) {
      for (final item in rawFields.whereType<Map>()) {
        final name = item['name']?.toString().trim() ?? '';
        if (name.isEmpty) continue;
        fields[name] = Map<String, dynamic>.from(item);
      }
    }

    String fieldValue(String name) {
      final field = fields[name];
      final normalized = field?['normalized_value'];
      if (normalized != null && normalized.toString().trim().isNotEmpty) {
        return normalized.toString().trim();
      }
      final value = field?['value'];
      return value?.toString().trim() ?? '';
    }

    final documentType = payload['document_type'];
    final documentTypeName = documentType is Map
        ? documentType['name']?.toString().trim() ?? ''
        : '';
    final type = documentTypeName.isNotEmpty
        ? documentTypeName.toUpperCase()
        : _typeFromField(fieldValue('document_type'));

    final series = fieldValue('series');
    final number = fieldValue('number');
    final serialNumber = [
      series,
      number,
    ].where((part) => part.isNotEmpty).join('-');

    final validations = <String>[];
    final rawValidations = payload['validations'];
    if (rawValidations is List) {
      for (final item in rawValidations.whereType<Map>()) {
        final severity = item['severity']?.toString();
        final message = item['message']?.toString().trim() ?? '';
        if (message.isNotEmpty && severity != 'info') {
          validations.add(message);
        }
      }
    }

    return OcrExpenseResult(
      ruc: fieldValue('issuer_ruc'),
      businessName: fieldValue('issuer_name'),
      type: type,
      date: fieldValue('issue_date'),
      serialNumber: serialNumber,
      subtotal: _toDouble(fieldValue('subtotal')),
      igv: _toDouble(fieldValue('tax_amount')),
      total: _toDouble(fieldValue('total')),
      rawText: '',
      isRemote: true,
      validationStatus: payload['validation_status']?.toString(),
      validationMessages: validations,
    );
  }

  static String _typeFromField(String value) {
    final upper = value.toUpperCase();
    if (upper.contains('FACTURA') || upper == 'INVOICE') return 'FACTURA';
    if (upper.contains('BOLETA') || upper == 'RECEIPT') return 'BOLETA';
    return upper;
  }

  static double _toDouble(String value) {
    if (value.trim().isEmpty) return 0.0;
    final normalized = value
        .replaceAll(RegExp(r'[^0-9,.-]'), '')
        .replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }
}
