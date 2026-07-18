import 'package:image_picker/image_picker.dart';

abstract class ExpensesDatasource {
  Future<String?> pickImage(ImageSource source);
  Future<String?> processImagePath(String imagePath);
}
