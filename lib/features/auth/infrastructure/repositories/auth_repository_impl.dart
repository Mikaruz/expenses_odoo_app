import 'package:oh_expenses_app/features/auth/domain/domain.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<void> validateConnection(String odooUrl, String database) {
    return _datasource.validateConnection(odooUrl, database);
  }

  @override
  Future<Authentication> login(
    String username,
    String password,
    String odooUrl,
    String database,
  ) {
    return _datasource.login(username, password, odooUrl, database);
  }
}
