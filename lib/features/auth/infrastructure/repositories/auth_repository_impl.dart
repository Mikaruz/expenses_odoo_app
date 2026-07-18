import 'package:oh_expenses_app/features/auth/domain/domain.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<Authentication> login(
    String username,
    String password,
    String odooUrl,
    String database,
  ) {
    return _datasource.login(username, password, odooUrl, database);
  }

  @override
  Future<void> resetPassword(String email, String odooUrl) {
    return _datasource.resetPassword(email, odooUrl);
  }
}
