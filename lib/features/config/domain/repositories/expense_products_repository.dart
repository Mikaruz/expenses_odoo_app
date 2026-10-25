import 'package:oh_expenses_app/features/config/domain/entities/expense_product.dart';

abstract class ExpenseProductsRepository {
  Future<List<ExpenseProduct>> getProducts({
    required String odooUrl,
    required String database,
    required String sessionId,
    required int userId,
  });
}
