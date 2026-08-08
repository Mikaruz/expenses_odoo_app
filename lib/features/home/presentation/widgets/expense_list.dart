import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:oh_expenses_app/features/home/presentation/widgets/expense_item.dart';

class ExpenseList extends ConsumerWidget {
  const ExpenseList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);

    return expensesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(child: CircularProgressIndicator(color: mainColor)),
      ),
      error: (_, _) => _ExpenseListMessage(
        icon: Icons.storage_outlined,
        title: 'No se pudieron leer tus gastos',
        message: 'Revisa el almacenamiento local e inténtalo nuevamente.',
        actionLabel: 'Reintentar',
        onAction: () => ref.invalidate(expensesProvider),
      ),
      data: (expenses) {
        if (expenses.isEmpty) {
          return const _ExpenseListMessage(
            icon: Icons.receipt_long_outlined,
            title: 'Sin gastos registrados',
            message:
                'Los comprobantes que guardes aparecerán aquí, incluso sin conexión.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 96),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return ExpenseItem(
              title: expense.displayName,
              date: expense.date.isEmpty ? 'Sin fecha' : expense.date,
              amount: expense.total,
              status: expense.syncStatus,
              onTap: () => context.push('/expense-detail', extra: expense),
            );
          },
        );
      },
    );
  }
}

class _ExpenseListMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ExpenseListMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 96),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: lineColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: mutedInkColor, size: 38),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: inkColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: mutedInkColor, height: 1.35),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
