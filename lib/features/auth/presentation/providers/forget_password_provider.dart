import 'package:formz/formz.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/auth/presentation/presentation.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forget_password_provider.g.dart';

@riverpod
class ForgetPasswordForm extends _$ForgetPasswordForm {
  @override
  ForgetPasswordFormState build() => ForgetPasswordFormState();

  void emailChanged(String value) {
    final email = Email.dirty(value);

    state = state.copyWith(
      email: email,
      isValid: Formz.validate([email, state.odooUrl]),
    );
  }

  void odooUrlChanged(String value) {
    final odooUrl = Url.dirty(value);

    state = state.copyWith(
      odooUrl: odooUrl,
      isValid: Formz.validate([state.email, odooUrl]),
    );
  }

  void resetState() {
    state = ForgetPasswordFormState();
  }

  Future<void> submit() async {
    final email = Email.dirty(state.email.value);
    final odooUrl = Url.dirty(state.odooUrl.value);

    state = state.copyWith(
      email: email,
      odooUrl: odooUrl,
      isFormPosted: true,
      isValid: Formz.validate([email, odooUrl]),
      isLoading: true,
      isSuccess: false,
    );

    try {
      final auth = ref.read(authProvider.notifier);
      await auth.resetPassword(email.value, odooUrl.value);

      Logger.info('Esperando simulación de 2 segundos...');
      await Future.delayed(const Duration(seconds: 2));

      Logger.success('Solicitud completada exitosamente');
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        errorMessage: '',
      );

      Logger.info(
        'Estado actualizado - isSuccess: ${state.isSuccess}, isLoading: ${state.isLoading}',
      );

      // Resetear el estado después de un pequeño delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (state.isSuccess) {
          Logger.info('Reseteando estado...');
          resetState();
        }
      });
    } catch (e) {
      Logger.error('Error al restablecer contraseña: $e');
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString().contains('CustomError')
            ? e.toString().replaceAll('CustomError: ', '')
            : 'Error al restablecer la contraseña. Verifica la dirección del servidor e inténtalo de nuevo.',
      );
      Logger.info(
        'Estado de error actualizado - errorMessage: ${state.errorMessage}',
      );
    }
  }
}

class ForgetPasswordFormState {
  final Email email;
  final Url odooUrl;
  final bool isFormPosted;
  final bool isValid;
  final bool isLoading;
  final bool isSuccess;
  final String errorMessage;

  ForgetPasswordFormState({
    this.email = const Email.pure(),
    this.odooUrl = const Url.pure(),
    this.isFormPosted = false,
    this.isValid = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage = '',
  });

  ForgetPasswordFormState copyWith({
    Email? email,
    Url? odooUrl,
    bool? isFormPosted,
    bool? isValid,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return ForgetPasswordFormState(
      email: email ?? this.email,
      odooUrl: odooUrl ?? this.odooUrl,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
