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
    Logger.info('Verificando identidad local...');

    final uid = await _storage.getValue<String>('offlineUid');
    final name = await _storage.getValue<String>('offlineName');
    final email = await _storage.getValue<String>('offlineEmail');
    final odooUrl = await _storage.getValue<String>('odooUrl');
    final database = await _storage.getValue<String>('odooDatabase');

    if (uid == null ||
        uid.trim().isEmpty ||
        name == null ||
        name.trim().isEmpty ||
        odooUrl == null ||
        odooUrl.trim().isEmpty ||
        database == null ||
        database.trim().isEmpty) {
      return logout();
    }

    _setLoggedUser(
      Authentication(uid: uid, name: name, email: email ?? '', sessionId: ''),
      isOffline: true,
    );
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

      // La identidad permite acceso offline; la contraseña no se persiste.
      await _storage.setKeyValue('username', username);
      await _storage.setKeyValue('odooUrl', odooUrl);
      await _storage.setKeyValue('odooDatabase', database);
      await _storage.setKeyValue('odooConnectionValidated', true);
      await _storage.setKeyValue('offlineUid', authentication.uid);
      await _storage.setKeyValue('offlineName', authentication.name);
      await _storage.setKeyValue('offlineEmail', authentication.email);
      await _storage.removeKey('password');

      _setLoggedUser(authentication);
    } on CustomError catch (e) {
      Logger.error("Error al iniciar sesión: ${e.message}");
      logout(e.message);
    } catch (e) {
      Logger.error("Error al iniciar sesión: ${e.toString()}");
      logout('Error inesperado al iniciar sesión.');
    }
  }

  Future<void> validateConnection(String odooUrl, String database) {
    return _authRepository.validateConnection(odooUrl, database);
  }

  void _setLoggedUser(Authentication authentication, {bool isOffline = false}) {
    Logger.success(
      isOffline ? 'Identidad local restaurada' : 'Usuario autenticado',
    );
    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: authentication,
      isOffline: isOffline,
      errorMessage: '',
    );
  }

  Future<void> logout([String? errorMessage]) async {
    if (errorMessage == null) {
      await _storage.removeKey('username');
      await _storage.removeKey('password');
      await _storage.removeKey('offlineUid');
      await _storage.removeKey('offlineName');
      await _storage.removeKey('offlineEmail');
    }

    Logger.info('Cerrando sesión...');
    state = state.copyWith(
      authStatus: AuthStatus.unauthenticated,
      clearUser: true,
      isOffline: false,
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
  final bool isOffline;
  final String errorMessage;

  const AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.isOffline = false,
    this.errorMessage = '',
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    Authentication? user,
    bool clearUser = false,
    bool? isOffline,
    String? errorMessage,
    String? deviceId,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      user: clearUser ? null : user ?? this.user,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
