import 'package:dio/dio.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/auth/domain/domain.dart';
import 'package:oh_expenses_app/features/auth/infrastructure/infrastructure.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

class AuthDatasourceImpl extends AuthDatasource {
  @override
  Future<Authentication> login(
    String username,
    String password,
    String odooUrl,
    String database,
  ) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: odooUrl.trim(),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await dio.post(
        '/web/session/authenticate',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'db': database.trim(),
            'login': username.trim(),
            'password': password,
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw CustomError('Respuesta inválida del servidor Odoo.');
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
              : 'No se pudo iniciar sesión en Odoo.',
        );
      }

      final authentication = AuthenticationMapper.jsonToEntity(response);

      return authentication;
    } on DioException catch (e) {
      handleDioError(e);
    } on CustomError {
      rethrow;
    } catch (e) {
      Logger.error(e.toString());
      throw CustomError('Error: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email, String odooUrl) {
    // TODO: implement resetPassword
    return Future.value();
  }
}
