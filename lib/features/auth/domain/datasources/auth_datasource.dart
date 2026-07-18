import 'package:oh_expenses_app/features/auth/domain/domain.dart';

abstract class AuthDatasource {
  Future<Authentication> login(
    String username,
    String password,
    String odooUrl,
  );
  Future<void> resetPassword(String email, String odooUrl);
}
