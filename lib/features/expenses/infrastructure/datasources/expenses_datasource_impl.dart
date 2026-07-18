import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';

class ExpensesDatasourceImpl extends ExpensesDatasource {
  @override
  Future<String?> pickImage(ImageSource source) async {
    try {
      final imagePicker = ImagePicker();

      Logger.info('Iniciando ImagePicker con fuente: $source');

      final XFile? imageFile = await imagePicker.pickImage(source: source);

      if (imageFile == null) {
        Logger.warning('Usuario canceló la selección de imagen');
        return null;
      }

      Logger.success('Imagen seleccionada: ${imageFile.path}');

      return imageFile.path;
    } catch (e) {
      Logger.error('Error al seleccionar imagen: $e');
      throw Exception('Error seleccionando imagen: $e');
    }
  }

  @override
  Future<String?> processImagePath(String imagePath) async {
    Logger.info('Iniciando procesamiento OCR para: $imagePath');
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );
        Logger.success(
          'OCR completado. Texto extraído: ${recognizedText.text.length} caracteres',
        );
        return recognizedText.text;
      } finally {
        textRecognizer.close();
        Logger.debug('TextRecognizer cerrado correctamente.');
      }
    } catch (e) {
      Logger.error('Error durante el OCR: $e');
      throw Exception('Error procesando imagen: $e');
    }
  }
}
