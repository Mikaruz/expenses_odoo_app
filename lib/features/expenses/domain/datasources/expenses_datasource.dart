import 'package:image_picker/image_picker.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/expense.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/expense_attachment.dart';

abstract class ExpensesDatasource {
  Future<String?> pickImage(ImageSource source);
  Future<String?> processImagePath(String imagePath);
  Future<List<Expense>> getExpenses({
    required String odooUrl,
    required String database,
    required String sessionId,
    required int userId,
  });
  Future<List<ExpenseAttachment>> getExpenseAttachments({
    required String odooUrl,
    required String sessionId,
    required int expenseId,
  });
}
