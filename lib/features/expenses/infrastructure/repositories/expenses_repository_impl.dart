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
}
