import 'package:flutter/material.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';

class ExpenseItem extends StatelessWidget {
  final String title;
  final String date;
  final double amount;
  final ExpenseSyncStatus status;
  final String? statusLabel;
  final VoidCallback? onTap;

  const ExpenseItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    this.statusLabel,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case ExpenseSyncStatus.pending:
        return warningColor;
      case ExpenseSyncStatus.synced:
        return successColor;
      case ExpenseSyncStatus.error:
        return dangerColor;
    }
  }

  String _getStatusText() {
    switch (status) {
      case ExpenseSyncStatus.pending:
        return 'Pendiente';
      case ExpenseSyncStatus.synced:
        return 'Sincronizado';
      case ExpenseSyncStatus.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: lineColor.withValues(alpha: 0.75)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 58,
                  decoration: BoxDecoration(
                    color: receiptColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: lineColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: mainColor,
                        size: 22,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 24,
                        height: 3,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: inkColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: mutedInkColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel ?? _getStatusText(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'S/ ${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: inkColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: mutedInkColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
