import 'package:flutter_test/flutter_test.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/mappers/expense_ocr_mapper.dart';

void main() {
  test('maps the Odoo OCR response without re-running local OCR', () {
    final result = ExpenseOcrMapper.fromApiPayload({
      'document_type': {'id': 1, 'name': 'Factura'},
      'validation_status': 'warning',
      'fields': [
        {
          'name': 'issuer_ruc',
          'value': '20100070970',
          'normalized_value': '20100070970',
        },
        {
          'name': 'issuer_name',
          'value': 'PROVEEDOR SAC',
          'normalized_value': 'PROVEEDOR SAC',
        },
        {'name': 'series', 'value': 'F001', 'normalized_value': 'F001'},
        {'name': 'number', 'value': '000123', 'normalized_value': '000123'},
        {
          'name': 'issue_date',
          'value': '2026-06-14',
          'normalized_value': '2026-06-14',
        },
        {'name': 'subtotal', 'value': '100.00', 'normalized_value': '100.00'},
        {'name': 'tax_amount', 'value': '18.00', 'normalized_value': '18.00'},
        {'name': 'total', 'value': '118.00', 'normalized_value': '118.00'},
      ],
      'validations': [
        {'severity': 'warning', 'message': 'Confirme el comprobante.'},
      ],
    });

    expect(result.isRemote, isTrue);
    expect(result.type, 'FACTURA');
    expect(result.ruc, '20100070970');
    expect(result.serialNumber, 'F001-000123');
    expect(result.subtotal, 100.0);
    expect(result.igv, 18.0);
    expect(result.total, 118.0);
    expect(result.validationMessages, ['Confirme el comprobante.']);
  });
}
