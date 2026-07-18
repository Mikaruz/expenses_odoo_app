import 'package:flutter/foundation.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/auth/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_router_provider.g.dart';

@riverpod
GoRouterNotifier goRouterNotifier(Ref ref) {
  final notifier = GoRouterNotifier();

  // Escuchar cambios del estado de autenticación
  ref.listen(authProvider, (previous, next) {
    Logger.info('GoRouterNotifier: authStatus changed to ${next.authStatus}');
    notifier.authStatus = next.authStatus;
  });

  return notifier;
}

class GoRouterNotifier extends ChangeNotifier {
  AuthStatus _authStatus = AuthStatus.checking;

  AuthStatus get authStatus => _authStatus;

  set authStatus(AuthStatus value) {
    if (_authStatus != value) {
      _authStatus = value;
      notifyListeners();
    }
  }
}
