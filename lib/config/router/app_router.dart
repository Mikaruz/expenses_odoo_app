import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/auth/auth.dart';
import 'package:oh_expenses_app/features/home/home.dart';
import 'package:oh_expenses_app/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final notifier = ref.watch(goRouterProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/forget-password',
        builder: (context, state) => const ForgetPasswordScreen(),
      ),

      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomePage()),
        routes: [],
      ),
      GoRoute(
        path: '/expense-detail',
        builder: (context, state) => const ExpenseDetailScreen(),
      ),
      GoRoute(
        path: '/expense-form',
        builder: (context, state) => const ExpenseFormScreen(),
      ),
    ],
    redirect: (context, state) {
      final AuthStatus authStatus = notifier.authStatus;
      final isGoingTo = state.uri.toString();

      if (authStatus == AuthStatus.checking) {
        return isGoingTo == '/splash' ? null : '/splash';
      }

      if (authStatus == AuthStatus.unauthenticated) {
        final publicRoutes = ['/login', '/forget-password'];
        return publicRoutes.contains(isGoingTo) ? null : '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        if (['/login', '/splash'].contains(isGoingTo)) {
          return '/home';
        }
      }

      return null;
    },
  );
}
