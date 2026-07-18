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
    final ocrState = ref.watch(ocrProvider);
    final userName = authState.user?.name ?? 'Usuario';

    return Scaffold(
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
            const SizedBox(height: 10),
            const SummaryCard(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Últimos movimientos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const ExpenseList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceActionSheet(context, ref),
        backgroundColor: mainColor,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar Foto'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final imagePath = await ref.read(ocrProvider.notifier).pickImage(ImageSource.camera);
                  if (imagePath != null && context.mounted) {
                    ref.read(ocrProvider.notifier).processImagePath(imagePath);
                    context.push('/expense-form');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final imagePath = await ref.read(ocrProvider.notifier).pickImage(ImageSource.gallery);
                  if (imagePath != null && context.mounted) {
                    ref.read(ocrProvider.notifier).processImagePath(imagePath);
                    context.push('/expense-form');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
