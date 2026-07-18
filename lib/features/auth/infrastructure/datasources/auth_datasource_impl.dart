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
  ) async {
    try {
      final dio = Dio(BaseOptions(baseUrl: odooUrl));

      final database = 'o18-jarusa-5-ene';

      final response = await dio.post(
        '/oh-expenses/api/auth/login',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'db': database, 'login': username, 'password': password},
      );

      Logger.info('Login response: ${response.data}');

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
