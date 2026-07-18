import 'package:dio/dio.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

Never handleDioError(DioException e) {
  Logger.error(e.toString());

  final errorMessage = switch (e.type) {
    DioExceptionType.connectionTimeout => 'Tiempo de conexión agotado',
    DioExceptionType.sendTimeout => 'Tiempo de envío agotado',
    DioExceptionType.receiveTimeout => 'Tiempo de recepción agotado',
    DioExceptionType.badResponse =>
      'Respuesta incorrecta del servidor: ${e.message}',
    DioExceptionType.cancel => 'Solicitud cancelada',
    _ => 'Verifica tu conexión a internet',
  };

  throw CustomError(errorMessage);
}
