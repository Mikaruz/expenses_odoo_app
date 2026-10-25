class ExpenseProduct {
  final int id;
  final String name;
  final String defaultCode;

  const ExpenseProduct({
    required this.id,
    required this.name,
    this.defaultCode = '',
  });

  Map<String, Object?> toJson() {
    return {'id': id, 'name': normalizeName(name), 'defaultCode': defaultCode};
  }

  factory ExpenseProduct.fromJson(Map<String, dynamic> json) {
    return ExpenseProduct(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: normalizeName(json['name']?.toString() ?? ''),
      defaultCode: json['defaultCode']?.toString().trim() ?? '',
    );
  }

  String get displayName => normalizeName(name);

  static String normalizeName(String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) return normalized;

    normalized = normalized.replaceFirst(RegExp(r'^\s*\[[^\]]+\]\s*'), '');
    final codePrefix = RegExp(
      r'^\s*[A-Za-z0-9][A-Za-z0-9_./-]*\s*-\s*(.+)$',
    ).firstMatch(normalized);
    if (codePrefix != null) normalized = codePrefix.group(1)!.trim();

    return switch (normalized.toLowerCase()) {
      'communication' => 'Comunicación',
      'expenses' => 'Gastos',
      'gifts' => 'Regalos',
      'meals' => 'Comidas',
      'mileage' => 'Kilometraje',
      'travel & accommodation' => 'Viaje y alojamiento',
      _ => normalized,
    };
  }
}
