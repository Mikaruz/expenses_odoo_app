import 'package:dio/dio.dart';
import 'package:oh_expenses_app/features/auth/domain/domain.dart';

class AuthenticationMapper {
  static Authentication jsonToEntity(Response response) {
    final data = response.data as Map<String, dynamic>;

    return Authentication(
      uid: data['uid'].toString(),
      name: data['name'],
      email: data['login'],
      sessionId: data['session_id'],
    );
  }
}
