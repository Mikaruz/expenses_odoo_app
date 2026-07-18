import 'package:flutter/foundation.dart';

/// Logger central del proyecto
/// Solo imprime en consola si está en modo debug.
/// Colores y emojis incluidos para destacar los mensajes.
class Logger {
  static void _log(String color, String emoji, String title, String message) {
    if (kDebugMode) {
      final time = DateTime.now().toIso8601String().substring(11, 19);
      print('$color[$time] $emoji [$title] → $message\x1B[0m');
    }
  }

  static void success(String message, {String title = 'SUCCESS'}) {
    _log('\x1B[32m', '✅', title, message);
  }

  static void info(String message, {String title = 'INFO'}) {
    _log('\x1B[36m', '💡', title, message);
  }

  static void warning(String message, {String title = 'WARNING'}) {
    _log('\x1B[33m', '⚠️', title, message);
  }

  static void error(String message, {String title = 'ERROR'}) {
    const int chunkSize = 800;
    for (int i = 0; i < message.length; i += chunkSize) {
      final end = (i + chunkSize < message.length)
          ? i + chunkSize
          : message.length;
      _log('\x1B[31m', '❌', title, message.substring(i, end));
    }
  }

  static void debug(String message, {String title = 'DEBUG'}) {
    _log('\x1B[35m', '🧩', title, message);
  }
}
