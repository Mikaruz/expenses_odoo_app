import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:oh_expenses_app/features/home/presentation/widgets/widgets.dart';
import 'package:oh_expenses_app/features/home/presentation/screens/profile_screen.dart';
import 'package:oh_expenses_app/features/expenses/presentation/providers/ocr_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'Usuario';

    return Scaffold(
      backgroundColor: paperColor,
      appBar: HomeAppBar(
        userName: userName,
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SummaryCard(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Últimos movimientos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: inkColor,
                        letterSpacing: -0.25,
                      ),
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Ver todo')),
                ],
              ),
            ),
            const ExpenseList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceActionSheet(context, ref),
        backgroundColor: inkColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.document_scanner_outlined),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: surfaceColor,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Agregar comprobante',
                  style: TextStyle(
                    color: inkColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'El OCR leerá RUC, fecha, serie, IGV y total para acelerar el registro.',
                  style: TextStyle(color: mutedInkColor, height: 1.35),
                ),
                const SizedBox(height: 16),
                _ImageSourceTile(
                  icon: Icons.camera_alt_outlined,
                  title: 'Tomar foto',
                  subtitle: 'Captura un comprobante físico',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final imagePath = await ref
                        .read(ocrProvider.notifier)
                        .pickImage(ImageSource.camera);
                    if (imagePath != null && context.mounted) {
                      ref
                          .read(ocrProvider.notifier)
                          .processImagePath(imagePath);
                      context.push('/expense-form');
                    }
                  },
                ),
                const SizedBox(height: 10),
                _ImageSourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Elegir de galería',
                  subtitle: 'Usa una imagen guardada',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final imagePath = await ref
                        .read(ocrProvider.notifier)
                        .pickImage(ImageSource.gallery);
                    if (imagePath != null && context.mounted) {
                      ref
                          .read(ocrProvider.notifier)
                          .processImagePath(imagePath);
                      context.push('/expense-form');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: receiptColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: lineColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: mainColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: inkColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: mutedInkColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: mutedInkColor),
            ],
          ),
        ),
      ),
    );
  }
}
