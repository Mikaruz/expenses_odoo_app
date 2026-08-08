import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/presentation/providers/expense_attachments_provider.dart';
import 'package:oh_expenses_app/features/expenses/presentation/providers/expenses_provider.dart';

class ExpenseDetailScreen extends ConsumerStatefulWidget {
  final LocalExpense? expense;

  const ExpenseDetailScreen({super.key, this.expense});

  @override
  ConsumerState<ExpenseDetailScreen> createState() =>
      _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends ConsumerState<ExpenseDetailScreen> {
  LocalExpense? _expense;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  @override
  Widget build(BuildContext context) {
    final currentExpense = _expense;
    if (currentExpense == null) {
      return const Scaffold(
        backgroundColor: paperColor,
        body: Center(child: Text('No se encontró el gasto local.')),
      );
    }

    final statusColor = _statusColor(currentExpense.syncStatus);
    final syncState = ref.watch(expenseSyncProvider);

    return Scaffold(
      backgroundColor: paperColor,
      appBar: AppBar(title: const Text('Detalle de gasto')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
                  'S/ ${currentExpense.total.toStringAsFixed(2)}',
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
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(currentExpense.syncStatus),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _DetailRow(label: 'Comercio', value: currentExpense.displayName),
              const Divider(height: 32, color: lineColor),
              _DetailRow(
                label: 'RUC',
                value: currentExpense.ruc.isEmpty
                    ? 'Sin RUC'
                    : currentExpense.ruc,
              ),
              const Divider(height: 32, color: lineColor),
              _DetailRow(
                label: currentExpense.isRemoteOnly
                    ? 'Categoría'
                    : 'Comprobante',
                value: currentExpense.isRemoteOnly
                    ? currentExpense.documentType
                    : '${currentExpense.documentType} ${currentExpense.documentNumber}'
                          .trim(),
              ),
              const Divider(height: 32, color: lineColor),
              _DetailRow(
                label: 'Fecha',
                value: currentExpense.date.isEmpty
                    ? 'Sin fecha'
                    : currentExpense.date,
              ),
              if (!currentExpense.isRemoteOnly) ...[
                const Divider(height: 32, color: lineColor),
                _DetailRow(
                  label: 'Subtotal',
                  value: 'S/ ${currentExpense.subtotal.toStringAsFixed(2)}',
                ),
                const Divider(height: 32, color: lineColor),
                _DetailRow(
                  label: 'Impuesto',
                  value:
                      'S/ ${currentExpense.igv.toStringAsFixed(2)} '
                      '(${currentExpense.taxRatePercentage.toStringAsFixed(2)}%)',
                ),
              ],
              const Divider(height: 32, color: lineColor),
              Text(
                currentExpense.isRemoteOnly
                    ? 'Adjuntos de Odoo'
                    : 'Comprobante local',
                style: TextStyle(
                  fontSize: 14,
                  color: mutedInkColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              if (currentExpense.isRemoteOnly &&
                  currentExpense.remoteId != null)
                _RemoteReceiptPreview(expenseId: currentExpense.remoteId!)
              else
                _LocalReceiptPreview(expense: currentExpense),
              if (!currentExpense.isRemoteOnly) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: syncState.isSyncing
                            ? null
                            : () => _editExpense(currentExpense),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            syncState.isSyncing ||
                                currentExpense.syncStatus ==
                                    ExpenseSyncStatus.synced
                            ? null
                            : () => _syncExpense(currentExpense),
                        icon: syncState.isSyncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.sync_rounded),
                        label: Text(
                          currentExpense.syncStatus == ExpenseSyncStatus.synced
                              ? 'Sincronizado'
                              : 'Sincronizar',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (currentExpense.lastSyncError?.isNotEmpty == true) ...[
                const SizedBox(height: 20),
                _SyncErrorNotice(message: currentExpense.lastSyncError!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _syncExpense(LocalExpense expense) async {
    final success = await ref
        .read(expenseSyncProvider.notifier)
        .syncExpense(expense);
    final updated = await ref
        .read(localExpensesRepositoryProvider)
        .getExpense(expense.id, expense.accountScope);
    if (!mounted) return;
    if (updated != null) setState(() => _expense = updated);
    final message = ref.read(expenseSyncProvider).message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.isNotEmpty
              ? message
              : success
              ? 'Gasto sincronizado con Odoo.'
              : 'No se pudo sincronizar el gasto.',
        ),
      ),
    );
  }

  Future<void> _editExpense(LocalExpense expense) async {
    final updated = await context.push<LocalExpense>(
      '/expense-form',
      extra: expense,
    );
    if (mounted && updated != null) setState(() => _expense = updated);
  }

  Color _statusColor(ExpenseSyncStatus status) {
    return switch (status) {
      ExpenseSyncStatus.pending => warningColor,
      ExpenseSyncStatus.synced => successColor,
      ExpenseSyncStatus.error => dangerColor,
    };
  }

  String _statusLabel(ExpenseSyncStatus status) {
    return switch (status) {
      ExpenseSyncStatus.pending => 'Pendiente',
      ExpenseSyncStatus.synced => 'Sincronizado',
      ExpenseSyncStatus.error => 'Error',
    };
  }
}

class _RemoteReceiptPreview extends ConsumerWidget {
  final int expenseId;

  const _RemoteReceiptPreview({required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachmentsAsync = ref.watch(expenseAttachmentsProvider(expenseId));
    return attachmentsAsync.when(
      loading: () => const _AttachmentPlaceholder(
        icon: Icons.cloud_download_outlined,
        label: 'Consultando adjuntos...',
        showLoader: true,
      ),
      error: (_, _) => const _AttachmentPlaceholder(
        icon: Icons.cloud_off_outlined,
        label: 'Inicia sesión nuevamente para consultar los adjuntos',
      ),
      data: (state) {
        if (state.attachments.isEmpty) {
          return const _AttachmentPlaceholder(
            icon: Icons.image_not_supported_outlined,
            label: 'Este gasto no tiene imágenes adjuntas',
          );
        }

        final baseUrl = state.odooUrl.replaceFirst(RegExp(r'/+$'), '');
        final headers = {'Cookie': 'session_id=${state.sessionId}'};
        return SizedBox(
          height: 260,
          child: PageView.builder(
            itemCount: state.attachments.length,
            itemBuilder: (context, index) {
              final attachment = state.attachments[index];
              final imageUrl = '$baseUrl/web/content/${attachment.id}';
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () =>
                        _showFullScreenImage(context, imageUrl, headers),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: receiptColor,
                        border: Border.all(color: lineColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          headers: headers,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) =>
                              const _AttachmentPlaceholder(
                                icon: Icons.broken_image_outlined,
                                label: 'No se pudo mostrar el adjunto',
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    Map<String, String> headers,
  ) {
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
                    headers: headers,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalReceiptPreview extends ConsumerWidget {
  final LocalExpense expense;

  const _LocalReceiptPreview({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathAsync = ref.watch(
      receiptPathProvider(expense.receiptRelativePath),
    );
    return pathAsync.when(
      loading: () => const _AttachmentPlaceholder(
        icon: Icons.image_outlined,
        label: 'Cargando comprobante...',
        showLoader: true,
      ),
      error: (_, _) => const _AttachmentPlaceholder(
        icon: Icons.broken_image_outlined,
        label: 'No se encontró el comprobante local',
      ),
      data: (path) {
        if (!File(path).existsSync()) {
          return const _AttachmentPlaceholder(
            icon: Icons.broken_image_outlined,
            label: 'No se encontró el comprobante local',
          );
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showFullScreenImage(context, path),
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
                    Image.file(
                      File(path),
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (_, _, _) => const _AttachmentPlaceholder(
                        icon: Icons.broken_image_outlined,
                        label: 'No se pudo mostrar la imagen',
                      ),
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

  void _showFullScreenImage(BuildContext context, String imagePath) {
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
                  child: Image.file(File(imagePath), fit: BoxFit.contain),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close_rounded),
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

class _SyncErrorNotice extends StatelessWidget {
  final String message;

  const _SyncErrorNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dangerColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: const TextStyle(color: dangerColor)),
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
          width: 104,
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
            value.isEmpty ? 'Sin información' : value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 15,
              color: inkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
