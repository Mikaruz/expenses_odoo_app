import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/auth/domain/domain.dart';
import 'package:oh_expenses_app/features/auth/infrastructure/infrastructure.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final _authRepository = AuthRepositoryImpl(AuthDatasourceImpl());
  late final KeyValueStorageService _storage;

  @override
  AuthState build() {
    _storage = KeyValueStorageServiceImpl();

    Future.microtask(() => _checkAuthStatus());
    return const AuthState();
  }

  Future<void> _checkAuthStatus() async {
    Logger.info("Verificando estado de autenticación...");

    // TODO: Implementar lógica de autenticación automática y guardar dirección del servidor

    // final username = await _storage.getValue<String>('username');
    // final password = await _storage.getValue<String>('password');
    //
    // if (username == null || password == null) {
    //   return logout();
    // }
    //
    // try {
    //   await login(username, password);
    // } catch (_) {
    //   logout();
    // }

    logout();
  }

  Future<void> login(
    String username,
    String password,
    String odooUrl,
    String database,
  ) async {
    try {
      final authentication = await _authRepository.login(
        username,
        password,
        odooUrl,
        database,
      );

      Logger.info(authentication.name);

      // * Guardar credenciales locales
      await _storage.setKeyValue('odooUrl', odooUrl);
      await _storage.setKeyValue('odooDatabase', database);

      _setLoggedUser(authentication);
    } on CustomError catch (e) {
      Logger.error("Error al iniciar sesión: ${e.message}");
      logout(e.message);
    } catch (e) {
      Logger.error("Error al iniciar sesión: ${e.toString()}");
      logout('Error inesperado al iniciar sesión.');
    }
  }

  void _setLoggedUser(Authentication authentication) {
    Logger.success("Usuario autenticado: ${authentication.name}");
    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: authentication,
      errorMessage: '',
    );
  }

  Future<void> resetPassword(String email, String odooUrl) async {
    try {
      await _authRepository.resetPassword(email, odooUrl);
      Logger.info(
        "Solicitud de restablecimiento de contraseña enviada para $email",
      );
    } on CustomError catch (e) {
      Logger.error(
        "Error al solicitar restablecimiento de contraseña: ${e.message}",
      );
      rethrow;
    } catch (_) {
      Logger.error(
        "Error inesperado al solicitar restablecimiento de contraseña.",
      );
      throw CustomError(
        'Error inesperado al solicitar restablecimiento de contraseña.',
      );
    }
  }

  Future<void> logout([String? errorMessage]) async {
    // await _storage.removeKey('username');
    // await _storage.removeKey('password');
    Logger.info("Cerrando sesión...");
    state = state.copyWith(
      authStatus: AuthStatus.unauthenticated,
      user: null,
      errorMessage: errorMessage,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }

  void setError(String message) {
    state = state.copyWith(
      authStatus: AuthStatus.unauthenticated,
      errorMessage: message,
    );
  }
}

class AuthState {
  final AuthStatus authStatus;
  final Authentication? user;
  final String errorMessage;

  const AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    Authentication? user,
    String? errorMessage,
    String? deviceId,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
