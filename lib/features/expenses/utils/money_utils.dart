class MoneyUtils {
  static double? parse(String raw) {
    var value = raw.trim();

    if (value.isEmpty) return null;

    value = value.replaceAll(RegExp(r'[^\d,.\-]'), '');

    if (value.isEmpty) return null;

    final hasComma = value.contains(',');
    final hasDot = value.contains('.');

    if (hasComma && hasDot) {
      final lastComma = value.lastIndexOf(',');
      final lastDot = value.lastIndexOf('.');

      if (lastComma > lastDot) {
        value = value.replaceAll('.', '').replaceAll(',', '.');
      } else {
        value = value.replaceAll(',', '');
      }
    } else if (hasComma) {
      final parts = value.split(',');

      if (parts.length > 1 && parts.last.length == 2) {
        final integerPart = parts.sublist(0, parts.length - 1).join('');
        value = '$integerPart.${parts.last}';
      } else {
        value = value.replaceAll(',', '');
      }
    } else if (hasDot) {
      final parts = value.split('.');

      if (parts.length > 2) {
        final integerPart = parts.sublist(0, parts.length - 1).join('');
        value = '$integerPart.${parts.last}';
      }
    }

    final parsed = double.tryParse(value);
    if (parsed == null || !parsed.isFinite) return null;

    return parsed;
  }

  static int? parseCents(String raw) {
    final amount = parse(raw);
    if (amount == null) return null;

    return toCents(amount);
  }

  static int toCents(double amount) => (amount * 100).round();

  static double fromCents(int cents) => cents / 100;

  static String formatCents(int cents) => fromCents(cents).toStringAsFixed(2);

  static double round2(double value) => fromCents(toCents(value));
}
