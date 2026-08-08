class ExpenseTax {
  final int id;
  final String name;
  final double ratePercentage;
  final String amountType;
  final String taxTypeUse;

  const ExpenseTax({
    required this.id,
    required this.name,
    required this.ratePercentage,
    required this.amountType,
    required this.taxTypeUse,
  });

  bool get supportsAutomaticCalculation =>
      amountType == 'percent' && ratePercentage >= 0;
}
