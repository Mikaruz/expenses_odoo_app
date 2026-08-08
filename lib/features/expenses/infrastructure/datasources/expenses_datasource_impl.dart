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

      Logger.success('Imagen seleccionada correctamente');

      return imageFile.path;
    } catch (e) {
      Logger.error('Error al seleccionar imagen: $e');
      throw Exception('Error seleccionando imagen: $e');
    }
  }

  @override
  Future<String?> processImagePath(String imagePath) async {
    Logger.info('Iniciando procesamiento OCR local');
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
      const pageSize = 100;
      final expenses = <Expense>[];
      var offset = 0;

      while (true) {
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
                'limit': pageSize,
                'offset': offset,
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
          final errorData = error is Map<String, dynamic>
              ? error['data']
              : null;
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
        expenses.addAll(
          result.whereType<Map<String, dynamic>>().map(
            ExpenseMapper.odooJsonToEntity,
          ),
        );
        if (result.length < pageSize) break;
        offset += pageSize;
      }

      return expenses;
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

  @override
  Future<int> createExpense({
    required String odooUrl,
    required String database,
    required String sessionId,
    required LocalExpense expense,
  }) async {
    if (database.trim().isEmpty || sessionId.trim().isEmpty) {
      throw CustomError('La sesión de Odoo no está disponible.');
    }

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
      final values = _buildExpenseValues(expense);
      final existingId = await _findExistingExpense(dio, expense.id);
      if (existingId != null) return existingId;

      final response = await dio.post(
        '/web/dataset/call_kw/hr.expense/create',
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'model': 'hr.expense',
            'method': 'create',
            'args': [values],
            'kwargs': <String, Object?>{},
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw CustomError('Respuesta inválida al crear el gasto en Odoo.');
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
              : 'Odoo rechazó la creación del gasto.',
        );
      }

      final result = data['result'];
      if (result is! num || result.toInt() <= 0) {
        throw CustomError('Odoo no devolvió el identificador del gasto.');
      }

      return result.toInt();
    } on DioException catch (e) {
      handleDioError(e);
    } on CustomError {
      rethrow;
    } catch (e) {
      Logger.error('Error creando gasto en Odoo: $e');
      throw CustomError('No se pudo crear el gasto en Odoo.');
    }
  }

  @override
  Future<void> updateExpense({
    required String odooUrl,
    required String database,
    required String sessionId,
    required LocalExpense expense,
  }) async {
    final remoteId = expense.remoteId;
    if (database.trim().isEmpty ||
        sessionId.trim().isEmpty ||
        remoteId == null) {
      throw CustomError('El gasto no tiene una referencia válida en Odoo.');
    }

    try {
      final dio = _buildOdooClient(odooUrl, sessionId);
      final response = await dio.post(
        '/web/dataset/call_kw/hr.expense/write',
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'model': 'hr.expense',
            'method': 'write',
            'args': [
              [remoteId],
              _buildExpenseValues(expense),
            ],
            'kwargs': <String, Object?>{},
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw CustomError('Respuesta inválida al actualizar el gasto en Odoo.');
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
              : 'Odoo rechazó la actualización del gasto.',
        );
      }
      if (data['result'] != true) {
        throw CustomError('Odoo no confirmó la actualización del gasto.');
      }
    } on DioException catch (e) {
      handleDioError(e);
    } on CustomError {
      rethrow;
    } catch (e) {
      Logger.error('Error actualizando gasto en Odoo: $e');
      throw CustomError('No se pudo actualizar el gasto en Odoo.');
    }
  }

  Map<String, Object?> _buildExpenseValues(LocalExpense expense) {
    final appliesTax =
        expense.taxId != null &&
        expense.taxTreatment != ExpenseTaxTreatment.exempt &&
        expense.taxTreatment != ExpenseTaxTreatment.unaffected &&
        expense.taxTreatment != ExpenseTaxTreatment.mixed;
    // Odoo 19 removed unit_amount; this is the writable receipt total.
    final values = <String, Object?>{
      'name': expense.displayName,
      'quantity': 1.0,
      'total_amount_currency': expense.total,
      'payment_mode': 'own_account',
      'description': _buildExpenseDescription(expense),
    };
    final date = _toOdooDate(expense.date);
    if (date != null) values['date'] = date;
    if (appliesTax) {
      values['tax_ids'] = [
        [
          6,
          0,
          [expense.taxId],
        ],
      ];
    }
    return values;
  }

  Dio _buildOdooClient(String odooUrl, String sessionId) {
    return Dio(
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
  }

  String _buildExpenseDescription(LocalExpense expense) {
    final details = <String>[
      'ID local: ${expense.id}',
      if (expense.ruc.isNotEmpty) 'RUC: ${expense.ruc}',
      if (expense.documentType.isNotEmpty || expense.documentNumber.isNotEmpty)
        'Comprobante: ${expense.documentType} ${expense.documentNumber}'.trim(),
      'Subtotal: S/ ${expense.subtotal.toStringAsFixed(2)}',
      'IGV: S/ ${expense.igv.toStringAsFixed(2)}',
      'Total: S/ ${expense.total.toStringAsFixed(2)}',
    ];
    return details.join('\n');
  }

  Future<int?> _findExistingExpense(Dio dio, String localId) async {
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
              ['description', 'ilike', 'ID local: $localId'],
            ],
            'fields': ['id'],
            'limit': 1,
          },
        },
        'id': DateTime.now().millisecondsSinceEpoch,
      },
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw CustomError('Respuesta inválida al verificar el gasto en Odoo.');
    }
    if (data['error'] != null) {
      throw CustomError('No se pudo verificar el gasto existente en Odoo.');
    }
    final result = data['result'];
    if (result is! List || result.isEmpty) return null;
    final first = result.first;
    if (first is! Map<String, dynamic> || first['id'] is! num) return null;
    return (first['id'] as num).toInt();
  }

  String? _toOdooDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final isoMatch = RegExp(
      r'^(\d{4})-(\d{1,2})-(\d{1,2})$',
    ).firstMatch(trimmed);
    final localMatch = RegExp(
      r'^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})$',
    ).firstMatch(trimmed);
    final match = isoMatch ?? localMatch;
    if (match == null) return null;

    final isIso = isoMatch != null;
    final yearValue = int.parse(match.group(isIso ? 1 : 3)!);
    final year = yearValue < 100 ? 2000 + yearValue : yearValue;
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(isIso ? 3 : 1)!);
    final parsed = DateTime.tryParse(
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}',
    );
    if (parsed == null ||
        parsed.year != year ||
        parsed.month != month ||
        parsed.day != day) {
      return null;
    }
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }
}
