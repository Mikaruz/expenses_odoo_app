import 'package:flutter_test/flutter_test.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/ocr_expense_result.dart';
import 'package:oh_expenses_app/features/expenses/utils/expense_amount_validator.dart';
import 'package:oh_expenses_app/features/expenses/utils/money_utils.dart';
import 'package:oh_expenses_app/features/expenses/utils/ocr_parser.dart';

void main() {
  group('OcrParser.parse', () {
    test('prioriza importe total y evita URLs/montos negativos del pie', () {
      const text = '''
TODO MODA S.A.C.
RUC 20100070970
BOLETA ELECTRONICA
B001-12345
OP. GRAVADA S/ 74.32
IGV 18% S/ 13.38
IMPORTE TOTAL S/ 87.70
Este documento puede ser consultado en:
http://asp403r.paperless.com.pe/PortalBija/
-27.90
PUEDE CONSULTAR NUESTRA POLITICA DE CAMBIOS EN:
https://pe.todomoda.com/terminos-y-condiciones
''';

      final result = OcrParser.parse(text);

      expect(result.subtotal, 74.32);
      expect(result.total, 87.70);
      expect(result.igv, 13.38);
      expect(result.taxTreatment, ExpenseTaxTreatment.taxable);
    });

    test('no interpreta IGV 18% como monto cuando no hay IGV explicito', () {
      const text = '''
RESTAURANTE DEMO S.A.C.
RUC 20512345678
FACTURA ELECTRONICA
F001-000123
TOTAL A PAGAR
S/ 118.00
IGV 18%
''';

      final result = OcrParser.parse(text);

      expect(result.subtotal, 100.00);
      expect(result.total, 118.00);
      expect(result.igv, 18.00);
      expect(result.igvWasInferred, isTrue);
      expect(result.subtotalWasInferred, isTrue);
    });

    test('detecta total cuando etiqueta y monto estan en lineas separadas', () {
      const text = '''
TIENDA PERUANA S.A.C.
RUC 20601234567
TICKET
TOTAL VENTA
45.90
EFECTIVO 50.00
VUELTO 4.10
''';

      final result = OcrParser.parse(text);

      expect(result.total, 45.90);
      expect(result.subtotal, 0.0);
      expect(result.igv, 0.0);
    });

    test('no infiere impuesto ni subtotal desde un total aislado', () {
      const text = '''
TIENDA PERUANA
TOTAL S/ 45.90
''';

      final result = OcrParser.parse(text);

      expect(result.total, 45.90);
      expect(result.subtotal, 0.0);
      expect(result.igv, 0.0);
      expect(result.taxTreatment, ExpenseTaxTreatment.unknown);
    });

    test('suma bases gravadas y exoneradas en un comprobante mixto', () {
      const text = '''
COMERCIO MIXTO S.A.C.
RUC 20512345678
FACTURA ELECTRONICA
F001-000123
OP. GRAVADA S/ 100.00
OP. EXONERADA S/ 20.00
IGV S/ 18.00
TOTAL S/ 138.00
''';

      final result = OcrParser.parse(text);

      expect(result.subtotal, 120.00);
      expect(result.igv, 18.00);
      expect(result.total, 138.00);
      expect(result.taxTreatment, ExpenseTaxTreatment.mixed);
    });

    test('considera IGV cero en un comprobante exonerado', () {
      const text = '''
COMERCIO EXONERADO
BOLETA ELECTRONICA
OP. EXONERADA S/ 50.00
TOTAL S/ 50.00
''';

      final result = OcrParser.parse(text);

      expect(result.subtotal, 50.00);
      expect(result.igv, 0.0);
      expect(result.total, 50.00);
      expect(result.taxTreatment, ExpenseTaxTreatment.exempt);
    });

    test('detecta una inconsistencia entre subtotal, IGV y total', () {
      const text = '''
SUBTOTAL S/ 100.00
IGV S/ 17.00
TOTAL S/ 118.00
''';

      final result = OcrParser.parse(text);
      final validation = ExpenseAmountValidator.validate(
        subtotal: result.subtotal,
        igv: result.igv,
        total: result.total,
      );

      expect(validation.isValid, isFalse);
      expect(validation.errorMessage, contains('subtotal + IGV = S/ 117.00'));
    });

    test('acepta montos con formato decimal peruano', () {
      expect(MoneyUtils.parse('1.234,56'), 1234.56);
      expect(MoneyUtils.parseCents('1.234,56'), 123456);
    });
  });

  group('ExpenseAmountValidator', () {
    test('acepta una operación gravada al 18%', () {
      final validation = ExpenseAmountValidator.validate(
        subtotal: 100,
        igv: 18,
        total: 118,
        taxTreatment: ExpenseTaxTreatment.taxable,
      );

      expect(validation.isValid, isTrue);
    });

    test('rechaza IGV distinto al 18% en una operación gravada', () {
      final validation = ExpenseAmountValidator.validate(
        subtotal: 100,
        igv: 17,
        total: 117,
        taxTreatment: ExpenseTaxTreatment.taxable,
      );

      expect(validation.isValid, isFalse);
      expect(validation.errorMessage, contains('IGV esperado al 18%'));
    });

    test('permite una base general distinta al 18% en una operación mixta', () {
      final validation = ExpenseAmountValidator.validate(
        subtotal: 120,
        igv: 18,
        total: 138,
        taxTreatment: ExpenseTaxTreatment.mixed,
      );

      expect(validation.isValid, isTrue);
    });

    test('rechaza IGV distinto de cero en una operación exonerada', () {
      final validation = ExpenseAmountValidator.validate(
        subtotal: 100,
        igv: 18,
        total: 118,
        taxTreatment: ExpenseTaxTreatment.exempt,
      );

      expect(validation.isValid, isFalse);
      expect(validation.errorMessage, contains('IGV S/ 0.00'));
    });
  });
}
