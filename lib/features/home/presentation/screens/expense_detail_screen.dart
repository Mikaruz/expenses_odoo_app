import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/presentation/providers/expense_attachments_provider.dart';
import 'package:oh_expenses_app/features/home/presentation/widgets/expense_item.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense? expense;

  const ExpenseDetailScreen({super.key, this.expense});

  Color _getStatusColor() {
    switch (mapExpenseStatus(expense?.state ?? 'draft')) {
      case ExpenseStatus.pending:
        return warningColor;
      case ExpenseStatus.approved:
        return successColor;
      case ExpenseStatus.rejected:
        return dangerColor;
    }
  }

  String _getStatusText() {
    return mapExpenseStatusLabel(expense?.state ?? 'draft');
  }

  @override
  Widget build(BuildContext context) {
    final currentExpense = expense;
    final title = currentExpense?.name ?? 'Gasto';
    final date = currentExpense?.date ?? 'Sin fecha';
    final amount = currentExpense?.totalAmount ?? 0;
    final category = currentExpense?.category.isNotEmpty == true
        ? currentExpense!.category
        : 'Sin categoría';
    final description = currentExpense?.description.isNotEmpty == true
        ? currentExpense!.description
        : 'Sin descripción registrada.';

    return Scaffold(
      backgroundColor: paperColor,
      appBar: AppBar(title: const Text('Detalle de gasto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: receiptColor,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: lineColor),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: mainColor,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'S/ ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: inkColor,
                  letterSpacing: -0.8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            _DetailRow(label: 'Título', value: title),
            const Divider(height: 32, color: lineColor),
            _DetailRow(label: 'Fecha', value: date),
            const Divider(height: 32, color: lineColor),
            _DetailRow(label: 'Categoría', value: category),
            const Divider(height: 32, color: lineColor),
            _DetailRow(label: 'Descripción', value: description),
            const Divider(height: 32, color: lineColor),
            const Text(
              'Comprobante',
              style: TextStyle(
                fontSize: 14,
                color: mutedInkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _ExpenseAttachmentPreview(expenseId: currentExpense?.id),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _ExpenseAttachmentPreview extends ConsumerWidget {
  final int? expenseId;

  const _ExpenseAttachmentPreview({required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = expenseId;
    if (id == null || id <= 0) {
      return const _AttachmentPlaceholder(
        icon: Icons.image_outlined,
        label: 'Sin comprobante disponible',
      );
    }

    final attachmentsAsync = ref.watch(expenseAttachmentsProvider(id));

    return attachmentsAsync.when(
      loading: () => const _AttachmentPlaceholder(
        icon: Icons.hourglass_empty_rounded,
        label: 'Buscando comprobante...',
        showLoader: true,
      ),
      error: (_, _) => const _AttachmentPlaceholder(
        icon: Icons.broken_image_outlined,
        label: 'No se pudo cargar el comprobante',
      ),
      data: (state) {
        if (state.attachments.isEmpty) {
          return const _AttachmentPlaceholder(
            icon: Icons.image_not_supported_outlined,
            label: 'Este gasto no tiene imagen adjunta',
          );
        }

        final attachment = state.attachments.first;
        final baseUrl = state.odooUrl.endsWith('/')
            ? state.odooUrl.substring(0, state.odooUrl.length - 1)
            : state.odooUrl;
        final imageUrl = '$baseUrl/web/content/${attachment.id}?download=false';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showFullScreenImage(
              context,
              imageUrl: imageUrl,
              sessionId: state.sessionId,
              title: attachment.name,
            ),
            child: Ink(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: receiptColor,
                border: Border.all(color: lineColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      headers: {'Cookie': 'session_id=${state.sessionId}'},
                      errorBuilder: (_, _, _) => const _AttachmentPlaceholder(
                        icon: Icons.broken_image_outlined,
                        label: 'No se pudo mostrar la imagen',
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const _AttachmentPlaceholder(
                          icon: Icons.image_outlined,
                          label: 'Cargando imagen...',
                          showLoader: true,
                        );
                      },
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: inkColor.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.open_in_full_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Ver',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage(
    BuildContext context, {
    required String imageUrl,
    required String sessionId,
    required String title,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.7,
                maxScale: 5,
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    headers: {'Cookie': 'session_id=$sessionId'},
                    errorBuilder: (_, _, _) => const Center(
                      child: Text(
                        'No se pudo mostrar la imagen',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showLoader;

  const _AttachmentPlaceholder({
    required this.icon,
    required this.label,
    this.showLoader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: receiptColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineColor),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showLoader)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: mainColor,
                  strokeWidth: 2.4,
                ),
              )
            else
              Icon(icon, size: 48, color: mutedInkColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: mutedInkColor)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: mutedInkColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: inkColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
