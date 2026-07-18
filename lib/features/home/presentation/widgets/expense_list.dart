import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/features/home/presentation/widgets/expense_item.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final expenses = [
      (title: 'Almuerzo Cliente', date: '12 Feb 2026', amount: 150.00, status: ExpenseStatus.pending),
      (title: 'Transporte Taxi', date: '11 Feb 2026', amount: 25.50, status: ExpenseStatus.approved),
      (title: 'Materiales Oficina', date: '10 Feb 2026', amount: 320.00, status: ExpenseStatus.approved),
      (title: 'Cena Equipo', date: '09 Feb 2026', amount: 450.00, status: ExpenseStatus.rejected),
       (title: 'Taxi Aeropuerto', date: '08 Feb 2026', amount: 60.00, status: ExpenseStatus.pending),
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80), // bottom padding for FAB
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return ExpenseItem(
          title: expense.title,
          date: expense.date,
          amount: expense.amount,
          status: expense.status,
          onTap: () {
            context.push('/expense-detail');
          },
        );
      },
    );
  }
}
