class ExpenseAttachment {
  final int id;
  final String name;
  final String mimetype;

  const ExpenseAttachment({
    required this.id,
    required this.name,
    required this.mimetype,
  });

  bool get isImage => mimetype.startsWith('image/');
}
