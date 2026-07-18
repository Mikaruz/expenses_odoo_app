import 'package:oh_expenses_app/features/expenses/domain/entities/ocr_expense_result.dart';

class OcrParser {
  static const double _igvRate = 0.18;

  // Acepta RUC con posibles separadores o errores OCR comunes:
  // 20O12345678 -> 20012345678
  static final RegExp _rucCandidateRegex = RegExp(
    r'(?<![A-Z0-9])(?:[0-9OILBS][\s.\-]*){11}(?![A-Z0-9])',
    caseSensitive: false,
  );

  static final RegExp _dateRegex = RegExp(
    r'\b(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})\b',
  );

  static final RegExp _serialRegex = RegExp(
    r'\b[FB]\d{3}[-\s]?\d{1,8}\b',
    caseSensitive: false,
  );

  static final RegExp _amountRegex = RegExp(
    r'(?:S\s*\/\.?|PEN|USD|\$)?\s*((?:\d{1,3}(?:[.,\s]\d{3})+|\d+)(?:[.,]\d{2})?)',
    caseSensitive: false,
  );

  static final RegExp _decimalAmountRegex = RegExp(
    r'(?:S\s*\/\.?|PEN|USD|\$)?\s*((?:\d{1,3}(?:[.,\s]\d{3})+|\d+)[.,]\d{2})',
    caseSensitive: false,
  );

  static OcrExpenseResult parse(String text) {
    final normalizedText = _normalizeText(text);

    final lines = normalizedText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final upperText = normalizedText.toUpperCase();

    final ruc = _extractRuc(lines);
    final businessName = _extractBusinessName(lines, ruc);

    final serialNumber = _extractSerial(normalizedText);
    final type = _extractType(upperText, ruc, serialNumber);

    final date = _dateRegex.firstMatch(normalizedText)?.group(0) ?? '';

    final total = _extractTotal(lines);
    final igv = _extractIgv(lines, total, upperText);

    return OcrExpenseResult(
      ruc: ruc,
      businessName: businessName,
      type: type,
      date: date,
      serialNumber: serialNumber,
      igv: igv,
      total: total,
      rawText: text,
    );
  }

  static String _normalizeText(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('：', ':')
        .replaceAll('S/.', 'S/')
        .replaceAll('S /', 'S/')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
  }

  // ---------------------------------------------------------------------------
  // RUC
  // ---------------------------------------------------------------------------

  static String _extractRuc(List<String> lines) {
    final candidates = <_RucCandidate>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final upperLine = line.toUpperCase();

      for (final match in _rucCandidateRegex.allMatches(line)) {
        final raw = match.group(0) ?? '';
        final ruc = _cleanRucCandidate(raw);

        if (ruc.length != 11) continue;

        var score = 0;

        if (_isValidRuc(ruc)) score += 80;
        if (upperLine.contains('RUC')) score += 40;
        if (ruc.startsWith('10') ||
            ruc.startsWith('15') ||
            ruc.startsWith('17') ||
            ruc.startsWith('20')) {
          score += 20;
        }

        // Los RUC suelen estar en la parte superior del comprobante.
        if (i <= 8) score += 10;

        candidates.add(_RucCandidate(value: ruc, score: score, lineIndex: i));
      }
    }

    if (candidates.isEmpty) return '';

    candidates.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.lineIndex.compareTo(b.lineIndex);
    });

    return candidates.first.value;
  }

  static String _cleanRucCandidate(String value) {
    final normalized = value
        .toUpperCase()
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll('L', '1')
        .replaceAll('B', '8')
        .replaceAll('S', '5');

    return normalized.replaceAll(RegExp(r'\D'), '');
  }

  static bool _isValidRuc(String ruc) {
    if (!RegExp(r'^\d{11}$').hasMatch(ruc)) return false;

    final weights = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2];

    var sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += int.parse(ruc[i]) * weights[i];
    }

    final remainder = sum % 11;
    var checkDigit = 11 - remainder;

    if (checkDigit == 10) checkDigit = 0;
    if (checkDigit == 11) checkDigit = 1;

    return checkDigit == int.parse(ruc[10]);
  }

  // ---------------------------------------------------------------------------
  // Razón social
  // ---------------------------------------------------------------------------

  static String _extractBusinessName(List<String> lines, String ruc) {
    // 1. Buscar etiquetas explícitas.
    final explicitRegex = RegExp(
      r'(?:RAZ[OÓ]N\s+SOCIAL|NOMBRE\s+O\s+RAZ[OÓ]N\s+SOCIAL|DENOMINACI[OÓ]N|SE[NÑ]OR(?:ES)?)\s*[:\-]?\s*(.+)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = explicitRegex.firstMatch(line);
      if (match != null) {
        final value = _cleanBusinessName(match.group(1) ?? '');
        if (_isLikelyBusinessName(value)) return value;
      }
    }

    // 2. Buscar líneas cercanas al RUC.
    final rucIndex = ruc.isEmpty
        ? -1
        : lines.indexWhere((line) => _cleanRucCandidate(line).contains(ruc));

    if (rucIndex >= 0) {
      final nearbyIndexes = [
        rucIndex - 3,
        rucIndex - 2,
        rucIndex - 1,
        rucIndex + 1,
        rucIndex + 2,
        rucIndex + 3,
      ];

      final candidates = <_BusinessNameCandidate>[];

      for (final index in nearbyIndexes) {
        if (index < 0 || index >= lines.length) continue;

        final candidate = _cleanBusinessName(lines[index]);
        if (!_isLikelyBusinessName(candidate)) continue;

        var score = 0;

        if (_hasBusinessSuffix(candidate)) score += 30;
        if (index < rucIndex) score += 20;
        if (candidate.length >= 8) score += 10;

        candidates.add(_BusinessNameCandidate(value: candidate, score: score));
      }

      if (candidates.isNotEmpty) {
        candidates.sort((a, b) => b.score.compareTo(a.score));
        return candidates.first.value;
      }
    }

    // 3. Fallback: buscar en las primeras líneas.
    for (final line in lines.take(8)) {
      final candidate = _cleanBusinessName(line);
      if (_isLikelyBusinessName(candidate)) return candidate;
    }

    return '';
  }

  static String _cleanBusinessName(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\-\:\.\s]+'), '')
        .replaceAll(RegExp(r'[\-\:\.\s]+$'), '')
        .trim();
  }

  static bool _isLikelyBusinessName(String value) {
    final upper = value.toUpperCase();

    if (value.length < 4) return false;
    if (!RegExp(r'[A-ZÁÉÍÓÚÑ]', caseSensitive: false).hasMatch(value))
      return false;

    final blockedWords = [
      'RUC',
      'FACTURA',
      'BOLETA',
      'TICKET',
      'RECIBO',
      'ELECTRONICA',
      'ELECTRÓNICA',
      'DIRECCION',
      'DIRECCIÓN',
      'TEL',
      'TELEFONO',
      'TELÉFONO',
      'FECHA',
      'HORA',
      'SERIE',
      'NUMERO',
      'NÚMERO',
      'TOTAL',
      'SUBTOTAL',
      'IGV',
      'OP.',
      'GRAVADA',
      'EXONERADA',
      'INAFECTA',
    ];

    for (final word in blockedWords) {
      if (upper.contains(word)) return false;
    }

    if (_dateRegex.hasMatch(value)) return false;
    if (_serialRegex.hasMatch(value)) return false;
    if (_decimalAmountRegex.hasMatch(value)) return false;

    return true;
  }

  static bool _hasBusinessSuffix(String value) {
    final upper = value.toUpperCase();

    return upper.contains('SAC') ||
        upper.contains('S.A.C') ||
        upper.contains('S.A.C.') ||
        upper.contains('EIRL') ||
        upper.contains('E.I.R.L') ||
        upper.contains('E.I.R.L.') ||
        upper.contains('SRL') ||
        upper.contains('S.R.L') ||
        upper.contains('S.R.L.') ||
        upper.contains('SA') ||
        upper.contains('S.A') ||
        upper.contains('S.A.');
  }

  // ---------------------------------------------------------------------------
  // Tipo, serie y número
  // ---------------------------------------------------------------------------

  static String _extractSerial(String text) {
    final match = _serialRegex.firstMatch(text);
    if (match == null) return '';

    return match.group(0)!.replaceAll(RegExp(r'\s+'), '-').toUpperCase();
  }

  static String _extractType(
    String upperText,
    String ruc,
    String serialNumber,
  ) {
    if (upperText.contains('FACTURA')) return 'FACTURA';
    if (upperText.contains('BOLETA')) return 'BOLETA';
    if (upperText.contains('TICKET')) return 'TICKET';
    if (upperText.contains('RECIBO')) return 'RECIBO';

    if (serialNumber.startsWith('F')) return 'FACTURA';
    if (serialNumber.startsWith('B')) return 'BOLETA';

    return '';
  }

  // ---------------------------------------------------------------------------
  // Total
  // ---------------------------------------------------------------------------

  static double _extractTotal(List<String> lines) {
    final candidates = <_AmountCandidate>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final upper = line.toUpperCase();

      if (!_looksLikeTotalLine(upper)) continue;
      if (_looksLikeNonTotalLine(upper)) continue;

      final amount = _lastAmountInLine(line);
      if (amount == null || amount <= 0) continue;

      var score = 100;

      if (upper.contains('TOTAL A PAGAR')) score += 60;
      if (upper.contains('IMPORTE TOTAL')) score += 50;
      if (upper.contains('TOTAL VENTA')) score += 40;
      if (RegExp(r'\bTOTAL\b').hasMatch(upper)) score += 30;

      // En comprobantes, el total suele estar más abajo.
      score += i;

      candidates.add(
        _AmountCandidate(value: amount, score: score, lineIndex: i, line: line),
      );
    }

    if (candidates.isNotEmpty) {
      candidates.sort((a, b) => b.score.compareTo(a.score));
      return _round2(candidates.first.value);
    }

    // Fallback: buscar montos en el último tercio del documento.
    final startIndex = (lines.length * 0.65).floor();
    final bottomLines = lines.skip(startIndex);

    final fallbackAmounts = <double>[];

    for (final line in bottomLines) {
      final upper = line.toUpperCase();

      // Evitar montos de vuelto, efectivo, descuentos o IGV.
      if (upper.contains('VUELTO') ||
          upper.contains('CAMBIO') ||
          upper.contains('DESCUENTO') ||
          upper.contains('DSCTO') ||
          upper.contains('IGV')) {
        continue;
      }

      for (final match in _decimalAmountRegex.allMatches(line)) {
        final amount = _parseAmount(match.group(1) ?? '');
        if (amount != null && amount > 0) {
          fallbackAmounts.add(amount);
        }
      }
    }

    if (fallbackAmounts.isEmpty) return 0.0;

    fallbackAmounts.sort();
    return _round2(fallbackAmounts.last);
  }

  static bool _looksLikeTotalLine(String upper) {
    return upper.contains('TOTAL A PAGAR') ||
        upper.contains('IMPORTE TOTAL') ||
        upper.contains('TOTAL VENTA') ||
        RegExp(r'\bTOTAL\b').hasMatch(upper);
  }

  static bool _looksLikeNonTotalLine(String upper) {
    final blocked = [
      'SUBTOTAL',
      'SUB TOTAL',
      'TOTAL DESCUENTO',
      'TOTAL DSCTO',
      'DESCUENTO TOTAL',
      'OP. GRAVADA',
      'OPERACION GRAVADA',
      'OPERACIÓN GRAVADA',
      'TOTAL OP',
      'TOTAL OPERACION',
      'TOTAL OPERACIÓN',
      'VALOR VENTA',
      'BASE IMPONIBLE',
      'ANTICIPO',
      'REDONDEO',
      'VUELTO',
      'CAMBIO',
      'EFECTIVO',
      'TARJETA',
      'PAGO CON',
      'IGV',
    ];

    return blocked.any(upper.contains);
  }

  // ---------------------------------------------------------------------------
  // IGV
  // ---------------------------------------------------------------------------

  static double _extractIgv(
    List<String> lines,
    double total,
    String upperText,
  ) {
    final explicitIgv = _extractExplicitIgv(lines);

    if (explicitIgv != null && explicitIgv >= 0) {
      return _round2(explicitIgv);
    }

    if (total <= 0) return 0.0;

    // Si el comprobante parece ser exonerado o inafecto y no se encontró IGV explícito,
    // es más seguro devolver 0 antes que inventar IGV.
    if (_looksExoneratedOrUnaffected(upperText)) {
      return 0.0;
    }

    // IGV incluido:
    // total = base + IGV
    // total = base * 1.18
    // IGV = total - (total / 1.18)
    // equivalente: IGV = total * 18 / 118
    return _round2(total * _igvRate / (1 + _igvRate));
  }

  static double? _extractExplicitIgv(List<String> lines) {
    final candidates = <_AmountCandidate>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final upper = line.toUpperCase();

      final hasIgvLabel =
          upper.contains('IGV') ||
          upper.contains('I.G.V') ||
          upper.contains('IMPUESTO GENERAL');

      if (!hasIgvLabel) continue;

      final amount = _lastAmountInLine(line);
      if (amount == null || amount < 0) continue;

      var score = 100;
      if (upper.contains('18%')) score += 20;
      score += i;

      candidates.add(
        _AmountCandidate(value: amount, score: score, lineIndex: i, line: line),
      );
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.first.value;
  }

  static bool _looksExoneratedOrUnaffected(String upperText) {
    final hasExonerated =
        upperText.contains('EXONERADA') ||
        upperText.contains('EXONERADO') ||
        upperText.contains('INAFECTA') ||
        upperText.contains('INAFECTO');

    final hasGravada =
        upperText.contains('GRAVADA') ||
        upperText.contains('GRAVADO') ||
        upperText.contains('IGV');

    return hasExonerated && !hasGravada;
  }

  // ---------------------------------------------------------------------------
  // Montos
  // ---------------------------------------------------------------------------

  static double? _lastAmountInLine(String line) {
    final matches = _amountRegex.allMatches(line).toList();
    if (matches.isEmpty) return null;

    for (final match in matches.reversed) {
      final amount = _parseAmount(match.group(1) ?? '');
      if (amount != null) return amount;
    }

    return null;
  }

  static double? _parseAmount(String raw) {
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
        // Formato: 1.234,56
        value = value.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Formato: 1,234.56
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

    return double.tryParse(value);
  }

  static double _round2(double value) {
    return (value * 100).roundToDouble() / 100;
  }
}

class _RucCandidate {
  final String value;
  final int score;
  final int lineIndex;

  const _RucCandidate({
    required this.value,
    required this.score,
    required this.lineIndex,
  });
}

class _BusinessNameCandidate {
  final String value;
  final int score;

  const _BusinessNameCandidate({required this.value, required this.score});
}

class _AmountCandidate {
  final double value;
  final int score;
  final int lineIndex;
  final String line;

  const _AmountCandidate({
    required this.value,
    required this.score,
    required this.lineIndex,
    required this.line,
  });
}
