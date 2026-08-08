import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/mappers/expense_ocr_mapper.dart';

class ExpenseOcrDatasourceImpl implements ExpenseOcrDatasource {
  @override
  Future<OcrExpenseResult> processImage({
    required String imagePath,
    required String odooUrl,
    required String database,
    required String sessionId,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw const ExpenseOcrRemoteException(
        'No se encontró la imagen seleccionada.',
      );
    }

    try {
      final bytes = await file.readAsBytes();
      final idempotencyKey = _idempotencyKey(bytes);
      final dio = Dio(
        BaseOptions(
          baseUrl: odooUrl.trim(),
          connectTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
          headers: {
            'Accept': 'application/json',
            'Cookie': 'session_id=$sessionId',
            'X-Odoo-Database': database.trim(),
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final response = await dio.post(
        '/expense_ocr/api/v1/session/documents',
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(
            imagePath,
            filename: path.basename(imagePath),
          ),
          'payment_mode': 'own_account',
        }),
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );

      if ((response.statusCode ?? 500) >= 400) {
        throw ExpenseOcrRemoteException(
          _serverErrorMessageFromData(response.data) ??
              'Odoo rechazó la solicitud OCR.',
        );
      }

      var payload = _readPayload(response.data);
      var state = payload['state']?.toString();
      if (state == 'queued' || state == 'processing') {
        payload = await _pollResult(dio, payload['status_url']?.toString());
        state = payload['state']?.toString();
      }

      if (state == 'error') {
        throw ExpenseOcrRemoteException(
          payload['error']?.toString() ??
              'Odoo no pudo procesar el comprobante.',
        );
      }
      if (state != 'review') {
        throw const ExpenseOcrRemoteException(
          'Odoo no devolvió un resultado OCR final.',
        );
      }

      return ExpenseOcrMapper.fromApiPayload(payload);
    } on ExpenseOcrRemoteException {
      rethrow;
    } on DioException catch (error) {
      final connectivityFailure = {
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      }.contains(error.type);
      throw ExpenseOcrRemoteException(
        _serverErrorMessage(error),
        isConnectivityFailure: connectivityFailure,
      );
    } on FileSystemException catch (error) {
      throw ExpenseOcrRemoteException(error.message);
    } catch (error) {
      Logger.error('Error OCR remoto: $error');
      throw ExpenseOcrRemoteException('No se pudo procesar el OCR remoto.');
    }
  }

  Future<Map<String, dynamic>> _pollResult(Dio dio, String? statusUrl) async {
    if (statusUrl == null || statusUrl.trim().isEmpty) {
      throw const ExpenseOcrRemoteException(
        'Odoo no devolvió la URL de consulta del OCR.',
      );
    }

    for (var attempt = 0; attempt < 30; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final response = await dio.get(statusUrl);
      final payload = _readPayload(response.data);
      final state = payload['state']?.toString();
      if (state != 'queued' && state != 'processing') return payload;
    }

    throw const ExpenseOcrRemoteException(
      'El OCR remoto tardó demasiado en responder.',
    );
  }

  Map<String, dynamic> _readPayload(Object? value) {
    if (value is Map<String, dynamic>) {
      final error = value['error'];
      // API errors are objects; a processed document can expose its own
      // error message as a string while remaining a valid OCR payload.
      if (error is Map) {
        throw ExpenseOcrRemoteException(
          error['message']?.toString() ?? 'Odoo rechazó la solicitud OCR.',
        );
      }
      return value;
    }
    throw const ExpenseOcrRemoteException(
      'Odoo devolvió una respuesta OCR inválida.',
    );
  }

  String _idempotencyKey(List<int> bytes) {
    final digest = sha256.convert(bytes).toString();
    return 'flutter-$digest';
  }

  String _serverErrorMessage(DioException error) {
    final message = _serverErrorMessageFromData(error.response?.data);
    if (message != null) return message;
    if (error.response?.statusCode == 401) {
      return 'La sesión de Odoo expiró. Inicia sesión nuevamente.';
    }
    return 'No se pudo conectar con el OCR de Odoo.';
  }

  String? _serverErrorMessageFromData(Object? data) {
    if (data is Map) {
      final remoteError = data['error'];
      if (remoteError is Map && remoteError['message'] != null) {
        return remoteError['message'].toString();
      }
    }
    return null;
  }
}
