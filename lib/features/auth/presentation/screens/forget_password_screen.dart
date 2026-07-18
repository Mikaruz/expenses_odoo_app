import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/features/auth/presentation/presentation.dart';
import 'package:oh_expenses_app/config/config.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            LoginHeader(title: 'Restablecer\ncontraseña', showBackButton: true),
            _ForgetPasswordForm(),
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

class _ForgetPasswordForm extends ConsumerStatefulWidget {
  const _ForgetPasswordForm();

  @override
  ConsumerState<_ForgetPasswordForm> createState() =>
      _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends ConsumerState<_ForgetPasswordForm> {
  void _showSuccessDialog() {
    if (!mounted) return;

    Logger.success('Correo enviado correctamente');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono de éxito animado
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_rounded,
                    size: 48,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                // Título
                Text(
                  '¡Correo Enviado!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Mensaje descriptivo
                Text(
                  'Se ha enviado un correo electrónico con las instrucciones para restablecer tu contraseña.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Por favor, revisa tu bandeja de entrada.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                // Botón de acción
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      if (mounted) {
                        context.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _submit() async {
    Logger.info('Botón de restablecer presionado');
    await ref.read(forgetPasswordFormProvider.notifier).submit();
    Logger.info('Submit completado');
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(forgetPasswordFormProvider);

    // Escuchar cambios en el estado
    ref.listen<ForgetPasswordFormState>(forgetPasswordFormProvider, (
      previous,
      next,
    ) {
      // Solo reaccionar cuando el estado cambia de loading a success/error
      if (previous?.isLoading == true && !next.isLoading) {
        if (next.isSuccess) {
          _showSuccessDialog();
        } else if (next.errorMessage.isNotEmpty) {
          _showErrorSnackbar(next.errorMessage);
        }
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Dirección del servidor',
            icon: Icons.dns,
            onChanged: (value) => ref
                .read(forgetPasswordFormProvider.notifier)
                .odooUrlChanged(value),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            label: 'Correo',
            icon: Icons.email,
            onChanged: (value) => ref
                .read(forgetPasswordFormProvider.notifier)
                .emailChanged(value),
          ),
          const SizedBox(height: 32),
          LoginButton(
            label: 'Restablecer',
            onPressed: formState.isLoading ? null : _submit,
            isLoading: formState.isLoading,
          ),
        ],
      ),
    );
  }
}
