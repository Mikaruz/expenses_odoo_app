import 'package:oh_expenses_app/features/expenses/utils/money_utils.dart';

enum ExpenseAnchor { subtotal, igv, total }

class ExpenseAmounts {
  final double subtotal;
  final double igv;
  final double total;

  const ExpenseAmounts({
    required this.subtotal,
    required this.igv,
    required this.total,
  });
}

/// Calcula [subtotal], [igv] y [total] partiendo de un campo ancla y de la
/// tasa del impuesto seleccionado. Los redondeos se hacen en céntimos para
/// evitar errores de punto flotante.
class ExpenseAmountSync {
  /// [ratePercentage] es el impuesto en porcentaje (18 para 0.18, 0 para
  /// exonerado/inafecto).
  static ExpenseAmounts? from({
    required double? anchorValue,
    required ExpenseAnchor anchor,
    required double ratePercentage,
  }) {
    if (anchorValue == null || !anchorValue.isFinite || anchorValue < 0) {
      return null;
    }

    final factor = ratePercentage / 100;
    final cents = MoneyUtils.toCents(anchorValue);

    switch (anchor) {
      case ExpenseAnchor.total:
        // El total ya incluye el impuesto: subtotal = total / (1 + tasa).
        if (factor <= 0) {
          return ExpenseAmounts(
            subtotal: anchorValue,
            igv: 0,
            total: anchorValue,
          );
        }
        final subtotalCents = (cents / (1 + factor)).round();
        return ExpenseAmounts(
          subtotal: MoneyUtils.fromCents(subtotalCents),
          igv: MoneyUtils.fromCents(cents - subtotalCents),
          total: anchorValue,
        );

      case ExpenseAnchor.igv:
        // igv = subtotal * tasa  =>  subtotal = igv / tasa.
        if (factor <= 0) {
          return ExpenseAmounts(
            subtotal: 0,
            igv: anchorValue,
            total: anchorValue,
          );
        }
        final subtotalCents = (cents / factor).round();
        return ExpenseAmounts(
          subtotal: MoneyUtils.fromCents(subtotalCents),
          igv: anchorValue,
          total: MoneyUtils.fromCents(subtotalCents + cents),
        );

      case ExpenseAnchor.subtotal:
        final igvCents = (cents * factor).round();
        return ExpenseAmounts(
          subtotal: anchorValue,
          igv: MoneyUtils.fromCents(igvCents),
          total: MoneyUtils.fromCents(cents + igvCents),
        );
    }
  }
}
