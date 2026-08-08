import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/presentation/providers/expenses_provider.dart';

class SummaryCard extends ConsumerWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final expenses = expensesAsync.when(
      data: (value) => value,
      error: (_, _) => const <LocalExpense>[],
      loading: () => const <LocalExpense>[],
    );
    final total = expenses.fold<double>(
      0,
      (previous, expense) => previous + expense.total,
    );
    final pending = expenses
        .where((expense) => expense.syncStatus == ExpenseSyncStatus.pending)
        .length;
    final synced = expenses
        .where((expense) => expense.syncStatus == ExpenseSyncStatus.synced)
        .length;
    final errors = expenses
        .where((expense) => expense.syncStatus == ExpenseSyncStatus.error)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: lineColor.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: inkColor.withValues(alpha: 0.06),
            offset: const Offset(0, 12),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  color: mainColor,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gastos locales',
                      style: TextStyle(
                        fontSize: 13,
                        color: mutedInkColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Disponibles sin conexión',
                      style: TextStyle(fontSize: 12, color: mutedInkColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'S/ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: inkColor,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricPill(
                label: 'Pendientes',
                value: pending.toString(),
                color: warningColor,
              ),
              const SizedBox(width: 10),
              _MetricPill(
                label: 'Sincronizados',
                value: synced.toString(),
                color: successColor,
              ),
              const SizedBox(width: 10),
              _MetricPill(
                label: 'Errores',
                value: errors.toString(),
                color: dangerColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: mutedInkColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
