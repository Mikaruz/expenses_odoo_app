import 'package:oh_expenses_app/features/auth/auth.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/infrastructure.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_attachments_provider.g.dart';

class ExpenseAttachmentsState {
  final String odooUrl;
  final String sessionId;
  final List<ExpenseAttachment> attachments;

  const ExpenseAttachmentsState({
    required this.odooUrl,
    required this.sessionId,
    required this.attachments,
  });
}

@riverpod
Future<ExpenseAttachmentsState> expenseAttachments(
  Ref ref,
  int expenseId,
) async {
  final authState = ref.read(authProvider);
  final user = authState.user;

  if (user == null) {
    throw CustomError('Inicia sesión para consultar adjuntos.');
  }

  final storage = KeyValueStorageServiceImpl();
  final odooUrl = await storage.getValue<String>('odooUrl');

  if (odooUrl == null || odooUrl.trim().isEmpty) {
    throw CustomError('Falta la URL del servidor Odoo.');
  }

  final repository = ExpensesRepositoryImpl(ExpensesDatasourceImpl());
  final attachments = await repository.getExpenseAttachments(
    odooUrl: odooUrl,
    sessionId: user.sessionId,
    expenseId: expenseId,
  );

  return ExpenseAttachmentsState(
    odooUrl: odooUrl,
    sessionId: user.sessionId,
    attachments: attachments,
  );
}
