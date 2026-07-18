import 'package:flutter/material.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/home/presentation/widgets/expense_item.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String title;
  final String date;
  final double amount;
  final ExpenseStatus status;

  const ExpenseDetailScreen({
    super.key,
    // Usamos valores por defecto si no se pasan, para simular datos mock
    this.title = 'Almuerzo Cliente',
    this.date = '12 Feb 2026',
    this.amount = 150.00,
    this.status = ExpenseStatus.pending,
  });

  Color _getStatusColor() {
    switch (status) {
      case ExpenseStatus.pending:
        return Colors.orange;
      case ExpenseStatus.approved:
        return Colors.green;
      case ExpenseStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (status) {
      case ExpenseStatus.pending:
        return 'Pendiente';
      case ExpenseStatus.approved:
        return 'Aprobado';
      case ExpenseStatus.rejected:
        return 'Rechazado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalle de Gasto'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long, color: mainColor, size: 40),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'S/ ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
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
            const Divider(height: 32),
            _DetailRow(label: 'Fecha', value: date),
            const Divider(height: 32),
            _DetailRow(label: 'Categoría', value: 'Alimentación'), // Dato mockeado
            const Divider(height: 32),
            const _DetailRow(
              label: 'Descripción', 
              value: 'Almuerzo con el cliente de la cuenta principal para discutir el nuevo proyecto.',
            ),
            const Divider(height: 32),
            const Text(
              'Comprobante',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Imagen del comprobante', style: TextStyle(color: Colors.grey)),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

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
              color: Colors.grey,
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
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
