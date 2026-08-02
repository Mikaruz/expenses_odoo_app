import 'package:image_picker/image_picker.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';

class ExpensesRepositoryImpl extends ExpensesRepository {
  final ExpensesDatasource _datasource;

  ExpensesRepositoryImpl(this._datasource);

  @override
  Future<String?> pickImage(ImageSource source) {
    return _datasource.pickImage(source);
  }

  @override
  Future<String?> processImagePath(String imagePath) {
    return _datasource.processImagePath(imagePath);
  }

  @override
  Future<List<Expense>> getExpenses({
    required String odooUrl,
    required String database,
    required String sessionId,
    required int userId,
  }) {
    return _datasource.getExpenses(
      odooUrl: odooUrl,
      database: database,
      sessionId: sessionId,
      userId: userId,
    );
  }

  @override
  Future<List<ExpenseAttachment>> getExpenseAttachments({
    required String odooUrl,
    required String sessionId,
    required int expenseId,
  }) {
    return _datasource.getExpenseAttachments(
      odooUrl: odooUrl,
      sessionId: sessionId,
      expenseId: expenseId,
    );
  }
}
