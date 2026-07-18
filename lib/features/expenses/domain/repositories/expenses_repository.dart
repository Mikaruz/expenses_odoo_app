import 'package:image_picker/image_picker.dart';

abstract class ExpensesRepository {
  Future<String?> pickImage(ImageSource source);
  Future<String?> processImagePath(String imagePath);
}
