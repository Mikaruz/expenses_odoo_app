import 'package:oh_expenses_app/features/expenses/domain/entities/ocr_expense_result.dart';
import 'package:oh_expenses_app/features/expenses/utils/money_utils.dart';

class ExpenseAmountValidation {
  final bool isValid;
  final String? errorMessage;
  final int? calculatedTotalCents;
  final int? expectedIgvCents;

  const ExpenseAmountValidation({
    required this.isValid,
    this.errorMessage,
    this.calculatedTotalCents,
    this.expectedIgvCents,
  });
}

class ExpenseAmountValidator {
  static const int _igvPercentage = 18;

  static ExpenseAmountValidation validate({
    required double? subtotal,
    required double? igv,
    required double? total,
    ExpenseTaxTreatment taxTreatment = ExpenseTaxTreatment.unknown,
  }) {
    if (subtotal == null || igv == null || total == null) {
      return const ExpenseAmountValidation(
        isValid: false,
        errorMessage: 'Completa subtotal, IGV y total.',
      );
    }

    if (!subtotal.isFinite || !igv.isFinite || !total.isFinite) {
      return const ExpenseAmountValidation(
        isValid: false,
        errorMessage: 'Los montos deben ser números válidos.',
      );
    }

    if (subtotal < 0 || igv < 0 || total < 0) {
      return const ExpenseAmountValidation(
        isValid: false,
        errorMessage: 'Los montos no pueden ser negativos.',
      );
    }

    final subtotalCents = MoneyUtils.toCents(subtotal);
    final igvCents = MoneyUtils.toCents(igv);
    final totalCents = MoneyUtils.toCents(total);
    final calculatedTotalCents = subtotalCents + igvCents;

    if (calculatedTotalCents != totalCents) {
      return ExpenseAmountValidation(
        isValid: false,
        calculatedTotalCents: calculatedTotalCents,
        errorMessage:
            'Los montos no son congruentes: subtotal + IGV = S/ '
            '${MoneyUtils.formatCents(calculatedTotalCents)}, pero el total es S/ '
            '${MoneyUtils.formatCents(totalCents)}.',
      );
    }

    if ((taxTreatment == ExpenseTaxTreatment.exempt ||
            taxTreatment == ExpenseTaxTreatment.unaffected) &&
        igvCents != 0) {
      return const ExpenseAmountValidation(
        isValid: false,
        errorMessage:
            'Un comprobante exonerado o inafecto debe registrar IGV S/ 0.00.',
      );
    }

    if (taxTreatment == ExpenseTaxTreatment.taxable) {
      final expectedIgvCents = (subtotalCents * _igvPercentage / 100).round();

      if (igvCents != expectedIgvCents) {
        return ExpenseAmountValidation(
          isValid: false,
          expectedIgvCents: expectedIgvCents,
          errorMessage:
              'Para una operación gravada, el IGV esperado al 18% es S/ '
              '${MoneyUtils.formatCents(expectedIgvCents)}.',
        );
      }
    }

    return const ExpenseAmountValidation(isValid: true);
  }
}
