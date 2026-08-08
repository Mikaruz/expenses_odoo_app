import 'package:oh_expenses_app/features/config/domain/entities/tax.dart';

abstract class TaxDatasource {
  Future<List<ExpenseTax>> getTaxes({
    required String odooUrl,
    required String database,
    required String sessionId,
  });
}
