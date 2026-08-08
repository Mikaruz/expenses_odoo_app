import 'package:oh_expenses_app/features/auth/domain/domain.dart';

abstract class AuthRepository {
  Future<void> validateConnection(String odooUrl, String database);

  Future<Authentication> login(
    String username,
    String password,
    String odooUrl,
    String database,
  );
}
