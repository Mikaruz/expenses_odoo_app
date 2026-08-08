import 'package:formz/formz.dart';
import 'package:oh_expenses_app/features/auth/presentation/presentation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

part 'login_form_provider.g.dart';

@riverpod
class LoginFormNotifier extends _$LoginFormNotifier {
  @override
  LoginFormState build() => LoginFormState();

  void emailChanged(String value) {
    final email = Email.dirty(value);

    state = state.copyWith(
      email: email,
      isValid: Formz.validate([email, state.password]),
    );
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);

    state = state.copyWith(
      password: password,
      isValid: Formz.validate([state.email, password]),
    );
  }

  void odooUrlChanged(String value) {
    final odooUrl = Url.dirty(value);

    state = state.copyWith(
      odooUrl: odooUrl,
      isValid: Formz.validate([state.email, state.password]),
    );
  }

  Future<void> submit() async {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      email: email,
      password: password,
      isFormPosted: true,
      isValid: Formz.validate([email, password]),
      isLoading: true,
    );

    if (!state.isValid) {
      state = state.copyWith(isLoading: false);

      return;
    }

    final auth = ref.read(authProvider.notifier);
    final storage = KeyValueStorageServiceImpl();
    final odooUrl = await storage.getValue<String>('odooUrl');
    final database = await storage.getValue<String>('odooDatabase');
    final connectionValidated =
        await storage.getValue<bool>('odooConnectionValidated') ?? false;

    final configuredUrl = Url.dirty(odooUrl ?? '');
    if (!configuredUrl.isValid ||
        database == null ||
        database.trim().isEmpty ||
        !connectionValidated) {
      auth.setError(
        'Configura y valida el servidor Odoo antes de iniciar sesión.',
      );
      state = state.copyWith(isLoading: false);

      return;
    }

    await auth.login(
      email.value,
      password.value,
      configuredUrl.value.trim(),
      database.trim(),
    );

    state = state.copyWith(isLoading: false);
  }
}

class LoginFormState {
  final Email email;
  final Password password;
  final Url odooUrl;
  final bool isFormPosted;
  final bool isValid;
  final bool isLoading;

  LoginFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.odooUrl = const Url.pure(),
    this.isFormPosted = false,
    this.isValid = false,
    this.isLoading = false,
  });

  LoginFormState copyWith({
    Email? email,
    Password? password,
    Url? odooUrl,
    bool? isFormPosted,
    bool? isValid,
    bool? isLoading,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      odooUrl: odooUrl ?? this.odooUrl,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
