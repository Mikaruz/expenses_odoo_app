class Expense {
  final int id;
  final String name;
  final String employeeName;
  final String date;
  final String state;
  final double totalAmount;
  final String currency;
  final String category;
  final String description;

  const Expense({
    required this.id,
    required this.name,
    required this.employeeName,
    required this.date,
    required this.state,
    required this.totalAmount,
    required this.currency,
    required this.category,
    required this.description,
  });
}
