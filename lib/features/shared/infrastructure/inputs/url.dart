import 'package:formz/formz.dart';

enum UrlError { empty, format }

class Url extends FormzInput<String, UrlError> {
  static final _urlRegExp = RegExp(
    r'^(https?:\/\/)' // http:// o https:// (REQUERIDO)
    r'(localhost|' // localhost
    r'(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,})|' // dominios
    r'(\d{1,3}\.){3}\d{1,3})' // IPv4
    r'(:\d+)?' // puerto opcional
    r'(\/.*)?$', // path opcional
  );

  const Url.pure() : super.pure('');
  const Url.dirty([super.value = '']) : super.dirty();

  String? get errorMessage {
    if (isPure || isValid) return null;

    switch (displayError) {
      case UrlError.empty:
        return 'El campo es requerido';
      case UrlError.format:
        return 'La dirección del servidor no es válida';
      default:
        return null;
    }
  }

  @override
  UrlError? validator(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return UrlError.empty;
    }

    if (!_urlRegExp.hasMatch(trimmed)) {
      return UrlError.format;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return UrlError.format;
    }

    return null;
  }
}
