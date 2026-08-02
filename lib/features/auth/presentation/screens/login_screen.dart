import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/auth/presentation/presentation.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: paperColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: isKeyboardOpen
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    LoginHeader(
                      title: 'Bienvenido',
                      subtitle: 'Ingresa tus credenciales\npara continuar',
                    ),
                    const _LoginForm(),
                    const Spacer(),
                    if (!isKeyboardOpen) const _LoginFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          '',
          style: TextStyle(color: mutedInkColor.withValues(alpha: 0.78)),
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
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final KeyValueStorageService _storage = KeyValueStorageServiceImpl();
  String _odooUrl = '';
  String _database = '';

  @override
  void initState() {
    super.initState();
    _loadOdooSettings();
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadOdooSettings() async {
    final odooUrl = await _storage.getValue<String>('odooUrl');
    final database = await _storage.getValue<String>('odooDatabase');

    if (!mounted) return;

    setState(() {
      _odooUrl = odooUrl ?? '';
      _database = database ?? '';
    });
  }

  Future<void> _submit() async {
    if (ref.read(loginFormProvider).isLoading) return;
    await ref.read(loginFormProvider.notifier).submit();
  }

  Future<void> _showOdooSettings() async {
    final result =
        await showModalBottomSheet<({String database, String odooUrl})>(
          context: context,
          isScrollControlled: true,
          backgroundColor: surfaceColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (_) => _OdooSettingsSheet(
            initialOdooUrl: _odooUrl,
            initialDatabase: _database,
          ),
        );

    if (!mounted || result == null) return;

    setState(() {
      _odooUrl = result.odooUrl;
      _database = result.database;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configuración Odoo guardada.'),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginFormProvider);
    final errorMessage = ref.watch(authProvider).errorMessage;

    void clearError() {
      ref.read(authProvider.notifier).clearError();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lineColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: mainColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.settings_outlined, color: mainColor),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servidor Odoo',
                        style: TextStyle(
                          color: inkColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'URL y base de datos',
                        style: TextStyle(color: mutedInkColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _showOdooSettings,
                  icon: const Icon(Icons.tune_rounded, color: inkColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          CustomTextField(
            controller: emailController,
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
            controller: passwordController,
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
                style: TextStyle(color: inkColor, fontWeight: FontWeight.w700),
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

class _OdooSettingsSheet extends StatefulWidget {
  final String initialOdooUrl;
  final String initialDatabase;

  const _OdooSettingsSheet({
    required this.initialOdooUrl,
    required this.initialDatabase,
  });

  @override
  State<_OdooSettingsSheet> createState() => _OdooSettingsSheetState();
}

class _OdooSettingsSheetState extends State<_OdooSettingsSheet> {
  late final TextEditingController odooUrlController;
  late final TextEditingController databaseController;
  final KeyValueStorageService _storage = KeyValueStorageServiceImpl();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    odooUrlController = TextEditingController(text: widget.initialOdooUrl);
    databaseController = TextEditingController(text: widget.initialDatabase);
  }

  @override
  void dispose() {
    odooUrlController.dispose();
    databaseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (isSaving) return;

    final normalizedUrl = _normalizeOdooUrl(odooUrlController.text);
    final odooUrl = Url.dirty(normalizedUrl);
    final database = databaseController.text.trim();

    if (!odooUrl.isValid || database.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ingresa una URL válida y la base de datos.'),
          backgroundColor: dangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      return;
    }

    setState(() => isSaving = true);

    await _storage.setKeyValue('odooUrl', odooUrl.value.trim());
    await _storage.setKeyValue('odooDatabase', database);

    if (!mounted) return;

    Navigator.of(
      context,
    ).pop((odooUrl: odooUrl.value.trim(), database: database));
  }

  String _normalizeOdooUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.startsWith(RegExp(r'https?://'))) {
      return trimmed;
    }

    return 'https://$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Conexión Odoo',
              style: TextStyle(
                color: inkColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Estos datos se usarán para autenticar por JSON-RPC en Odoo 19.',
              style: TextStyle(color: mutedInkColor, height: 1.35),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: odooUrlController,
              label: 'URL del servidor',
              icon: Icons.dns_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: databaseController,
              label: 'Base de datos',
              icon: Icons.storage_outlined,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 20),
            LoginButton(
              label: 'Guardar configuración',
              isLoading: isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
