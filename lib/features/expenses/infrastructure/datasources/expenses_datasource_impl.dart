import 'package:dio/dio.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/mappers/expense_mapper.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

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

  @override
  Future<List<Expense>> getExpenses({
    required String odooUrl,
    required String database,
    required String sessionId,
    required int userId,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: odooUrl.trim(),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'session_id=$sessionId',
          },
        ),
      );

      final response = await dio.post(
        '/web/dataset/call_kw/hr.expense/search_read',
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'model': 'hr.expense',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'domain': [
                ['employee_id.user_id', '=', userId],
              ],
              'fields': [
                'id',
                'name',
                'employee_id',
                'date',
                'state',
                'total_amount',
                'total_amount_currency',
                'currency_id',
                'product_id',
                'description',
              ],
              'limit': 50,
              'order': 'date desc, id desc',
            },
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw CustomError('Respuesta inválida al consultar gastos.');
      }

      final error = data['error'];
      if (error != null) {
        final errorData = error is Map<String, dynamic> ? error['data'] : null;
        final message = errorData is Map<String, dynamic>
            ? errorData['message']
            : null;
        throw CustomError(
          message?.toString().isNotEmpty == true
              ? message.toString()
              : 'No se pudieron obtener los gastos desde Odoo.',
        );
      }

      final result = data['result'];
      if (result is! List) {
        throw CustomError('Odoo no devolvió una lista de gastos válida.');
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(ExpenseMapper.odooJsonToEntity)
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    } on CustomError {
      rethrow;
    } catch (e) {
      Logger.error(e.toString());
      throw CustomError('Error consultando gastos: ${e.toString()}');
    }
  }

  @override
  Future<List<ExpenseAttachment>> getExpenseAttachments({
    required String odooUrl,
    required String sessionId,
    required int expenseId,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: odooUrl.trim(),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'session_id=$sessionId',
          },
        ),
      );

      final response = await dio.post(
        '/web/dataset/call_kw/ir.attachment/search_read',
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'model': 'ir.attachment',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'domain': [
                ['res_model', '=', 'hr.expense'],
                ['res_id', '=', expenseId],
                ['mimetype', 'ilike', 'image/'],
              ],
              'fields': ['id', 'name', 'mimetype'],
              'limit': 10,
              'order': 'id desc',
            },
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw CustomError('Respuesta inválida al consultar adjuntos.');
      }

      final error = data['error'];
      if (error != null) {
        final errorData = error is Map<String, dynamic> ? error['data'] : null;
        final message = errorData is Map<String, dynamic>
            ? errorData['message']
            : null;
        throw CustomError(
          message?.toString().isNotEmpty == true
              ? message.toString()
              : 'No se pudieron obtener los adjuntos del gasto.',
        );
      }

      final result = data['result'];
      if (result is! List) {
        throw CustomError('Odoo no devolvió una lista de adjuntos válida.');
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(ExpenseAttachmentMapper.odooJsonToEntity)
          .where((attachment) => attachment.isImage)
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    } on CustomError {
      rethrow;
    } catch (e) {
      Logger.error(e.toString());
      throw CustomError('Error consultando adjuntos: ${e.toString()}');
    }
  }
}
