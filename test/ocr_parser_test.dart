import 'package:flutter_test/flutter_test.dart';
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

      expect(result.total, 87.70);
      expect(result.igv, 13.38);
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

      expect(result.total, 118.00);
      expect(result.igv, 18.00);
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
    });
  });
}
