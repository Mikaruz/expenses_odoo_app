import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/features/auth/auth.dart';
import 'package:oh_expenses_app/config/config.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: paperColor,
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: inkColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: inkColor.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Usuario',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: inkColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'usuario@correo.com',
              style: const TextStyle(fontSize: 14, color: mutedInkColor),
            ),
            const SizedBox(height: 40),
            _ProfileOption(
              icon: Icons.person_outline,
              title: 'Editar Perfil',
              onTap: () {},
            ),
            _ProfileOption(
              icon: Icons.settings_outlined,
              title: 'Configuración',
              onTap: () => context.push('/tax-config'),
            ),
            _ProfileOption(
              icon: Icons.help_outline,
              title: 'Ayuda y Soporte',
              onTap: () {},
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dangerColor.withValues(alpha: 0.10),
                  foregroundColor: dangerColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: lineColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: mainColor),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: inkColor,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: mutedInkColor),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
      ),
    );
  }
}
