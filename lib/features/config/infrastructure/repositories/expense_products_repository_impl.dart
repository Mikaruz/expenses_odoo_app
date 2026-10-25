import 'package:oh_expenses_app/features/config/domain/domain.dart';

class ExpenseProductsRepositoryImpl implements ExpenseProductsRepository {
  final ExpenseProductsDatasource _datasource;

  ExpenseProductsRepositoryImpl(this._datasource);

  @override
  Future<List<ExpenseProduct>> getProducts({
    required String odooUrl,
    required String database,
    required String sessionId,
    required int userId,
  }) {
    return _datasource.getProducts(
      odooUrl: odooUrl,
      database: database,
      sessionId: sessionId,
      userId: userId,
    );
  }
}
