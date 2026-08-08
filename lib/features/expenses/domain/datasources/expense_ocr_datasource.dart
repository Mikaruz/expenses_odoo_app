import 'package:oh_expenses_app/features/expenses/domain/entities/ocr_expense_result.dart';

class ExpenseOcrRemoteException implements Exception {
  final String message;
  final bool isConnectivityFailure;

  const ExpenseOcrRemoteException(
    this.message, {
    this.isConnectivityFailure = false,
  });

  @override
  String toString() => message;
}

abstract class ExpenseOcrDatasource {
  Future<OcrExpenseResult> processImage({
    required String imagePath,
    required String odooUrl,
    required String database,
    required String sessionId,
  });
}
