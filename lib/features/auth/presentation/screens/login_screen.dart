import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/auth/presentation/presentation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            LoginHeader(
              title: 'Bienvenido',
              subtitle: 'Ingresa tus credenciales\npara continuar',
            ),
            _LoginForm(),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Text(
                  'Powered By BYR / EYM',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final serverFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  @override
  void dispose() {
    serverFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(loginFormProvider).isLoading) return;
    await ref.read(loginFormProvider.notifier).submit();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginFormProvider);
    final errorMessage = ref.watch(authProvider).errorMessage;

    void clearError() {
      ref.read(authProvider.notifier).clearError();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Dirección del servidor',
            icon: Icons.dns,
            focusNode: serverFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(emailFocus);
            },
            onChanged: (value) =>
                ref.read(loginFormProvider.notifier).odooUrlChanged(value),
            errorText: formState.isFormPosted
                ? formState.odooUrl.errorMessage
                : null,
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Correo',
            icon: Icons.person,
            focusNode: emailFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(passwordFocus);
            },
            onChanged: (value) =>
                ref.read(loginFormProvider.notifier).emailChanged(value),
            errorText: formState.isFormPosted
                ? formState.email.errorMessage
                : null,
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Contraseña',
            icon: Icons.lock,
            isPassword: true,
            focusNode: passwordFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) async {
              FocusScope.of(context).unfocus();
              await _submit();
            },
            onChanged: (value) =>
                ref.read(loginFormProvider.notifier).passwordChanged(value),
            errorText: formState.isFormPosted
                ? formState.password.errorMessage
                : null,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.push('/forget-password'),
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: mainColor, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ErrorMessage(errorMessage: errorMessage, clearError: clearError),
          const SizedBox(height: 16),
          LoginButton(
            label: 'Ingresar',
            isLoading: formState.isLoading,
            onPressed: formState.isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
