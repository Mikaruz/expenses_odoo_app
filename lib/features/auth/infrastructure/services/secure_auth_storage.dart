import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AuthSecretStorage {
  Future<String?> readPassword();

  Future<void> savePassword(String password);

  Future<void> clearPassword();
}

class SecureAuthStorage implements AuthSecretStorage {
  static const passwordKey = 'odooPassword';

  final FlutterSecureStorage _storage;

  SecureAuthStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> readPassword() {
    return _storage.read(key: passwordKey);
  }

  @override
  Future<void> savePassword(String password) {
    return _storage.write(key: passwordKey, value: password);
  }

  @override
  Future<void> clearPassword() {
    return _storage.delete(key: passwordKey);
  }
}
