import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oh_expenses_app/config/http/handle_dio_error.dart';
import 'package:oh_expenses_app/features/shared/infrastructure/errors/custom_error.dart';

void main() {
  test('trata un fallo de resolución DNS como error de conexión', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/web/database/list'),
      type: DioExceptionType.connectionError,
      error: const SocketException("Failed host lookup: 'sunnyideas-odoo.teh'"),
    );

    expect(
      () => handleDioError(error),
      throwsA(
        isA<CustomError>().having(
          (error) => error.message,
          'message',
          'No se pudo conectar con el servidor',
        ),
      ),
    );
  });

  test('informa cuando el servidor rechaza la conexión', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/web/database/list'),
      type: DioExceptionType.connectionError,
      error: const SocketException('Connection refused'),
    );

    expect(
      () => handleDioError(error),
      throwsA(
        isA<CustomError>().having(
          (error) => error.message,
          'message',
          'No se pudo conectar con el servidor',
        ),
      ),
    );
  });
}
