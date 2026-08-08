import 'package:oh_expenses_app/features/config/domain/domain.dart';

class TaxRepositoryImpl extends TaxRepository {
  final TaxDatasource _datasource;

  TaxRepositoryImpl(this._datasource);

  @override
  Future<List<ExpenseTax>> getTaxes({
    required String odooUrl,
    required String database,
    required String sessionId,
  }) {
    return _datasource.getTaxes(
      odooUrl: odooUrl,
      database: database,
      sessionId: sessionId,
    );
  }
}
