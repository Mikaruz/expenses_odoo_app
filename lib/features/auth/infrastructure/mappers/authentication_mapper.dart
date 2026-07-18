import 'package:dio/dio.dart';
import 'package:oh_expenses_app/features/auth/domain/domain.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

class AuthenticationMapper {
  static Authentication jsonToEntity(Response response) {
    final data = response.data as Map<String, dynamic>;
    final result = data['result'];

    if (result is! Map<String, dynamic>) {
      throw CustomError('No se recibió información de sesión desde Odoo.');
    }

    final uid = result['uid'];
    if (uid == null || uid == false) {
      throw CustomError('Credenciales o base de datos inválidas.');
    }

    final sessionId = _getSessionId(response, result);
    if (sessionId == null || sessionId.isEmpty) {
      throw CustomError('Odoo no devolvió una sesión válida.');
    }

    return Authentication(
      uid: uid.toString(),
      name: (result['name'] ?? result['username'] ?? 'Usuario').toString(),
      email: (result['username'] ?? result['login'] ?? '').toString(),
      sessionId: sessionId,
    );
  }

  static String? _getSessionId(Response response, Map<String, dynamic> result) {
    final resultSessionId = result['session_id']?.toString();
    if (resultSessionId != null && resultSessionId.isNotEmpty) {
      return resultSessionId;
    }

    final cookies = response.headers.map['set-cookie'] ?? const <String>[];
    for (final cookie in cookies) {
      final match = RegExp(r'session_id=([^;]+)').firstMatch(cookie);
      if (match != null) return match.group(1);
    }

    return null;
  }
}
