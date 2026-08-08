import 'package:oh_expenses_app/features/expenses/domain/entities/ocr_expense_result.dart';
import 'package:oh_expenses_app/features/expenses/utils/expense_amount_sync.dart';
import 'package:oh_expenses_app/features/expenses/utils/money_utils.dart';

class OcrParser {
  static const double defaultTaxRatePercentage = 18.0;

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
    r'(?:S\s*\/\.?|PEN|USD|\$)?\s*(-?(?:\d{1,3}(?:[.,\s]\d{3})+|\d+)(?:[.,]\d{1,2})?)',
    caseSensitive: false,
  );

  static final RegExp _decimalAmountRegex = RegExp(
    r'(?:S\s*\/\.?|PEN|USD|\$)?\s*(-?(?:\d{1,3}(?:[.,\s]\d{3})+|\d+)[.,]\d{1,2})',
    caseSensitive: false,
  );

  static OcrExpenseResult parse(
    String text, {
    double ratePercentage = defaultTaxRatePercentage,
  }) {
    final effectiveRate = ratePercentage.isFinite && ratePercentage >= 0
        ? ratePercentage
        : defaultTaxRatePercentage;
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
    final taxTreatment = _extractTaxTreatment(lines, upperText);
    final explicitIgv = _extractExplicitIgv(lines);
    final isTaxFree =
        taxTreatment == ExpenseTaxTreatment.exempt ||
        taxTreatment == ExpenseTaxTreatment.unaffected;
    final canUseTotalAsAnchor =
        total > 0 &&
        taxTreatment != ExpenseTaxTreatment.mixed &&
        _canDeriveAmount(upperText);

    double igv;
    _SubtotalExtraction subtotalExtraction;
    var igvWasInferred = false;

    if (canUseTotalAsAnchor) {
      final amounts = ExpenseAmountSync.from(
        anchorValue: total,
        anchor: ExpenseAnchor.total,
        ratePercentage: isTaxFree ? 0 : effectiveRate,
      )!;
      igv = amounts.igv;
      subtotalExtraction = _SubtotalExtraction(
        value: amounts.subtotal,
        wasInferred: true,
      );
      igvWasInferred = !isTaxFree;
    } else {
      igv = _extractIgv(
        lines,
        total,
        upperText,
        taxTreatment,
        explicitIgv,
        effectiveRate,
      );
      subtotalExtraction = _extractSubtotal(
        lines,
        total: total,
        igv: igv,
        taxTreatment: taxTreatment,
        upperText: upperText,
      );
      igvWasInferred = explicitIgv == null && igv > 0;
    }

    return OcrExpenseResult(
      ruc: ruc,
      businessName: businessName,
      type: type,
      date: date,
      serialNumber: serialNumber,
      subtotal: subtotalExtraction.value,
      igv: igv,
      total: total,
      taxTreatment: taxTreatment,
      igvWasInferred: igvWasInferred,
      subtotalWasInferred: subtotalExtraction.wasInferred,
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
    if (!RegExp(r'[A-ZÁÉÍÓÚÑ]', caseSensitive: false).hasMatch(value)) {
      return false;
    }

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

      if (_looksLikeNoiseLine(upper)) continue;
      if (!_looksLikeTotalLine(upper)) continue;
      if (_looksLikeNonTotalLine(upper)) continue;

      var amount = _lastDecimalAmountInLine(line) ?? _lastAmountInLine(line);
      var amountLineIndex = i;

      // En OCR real la etiqueta TOTAL suele quedar en una línea y el importe en la siguiente.
      if (amount == null) {
        for (var offset = 1; offset <= 2; offset++) {
          final nextIndex = i + offset;
          if (nextIndex >= lines.length) break;

          final nextLine = lines[nextIndex];
          final nextUpper = nextLine.toUpperCase();
          if (_looksLikeNoiseLine(nextUpper) ||
              _looksLikeNonTotalLine(nextUpper)) {
            continue;
          }

          amount = _lastDecimalAmountInLine(nextLine);
          if (amount != null) {
            amountLineIndex = nextIndex;
            break;
          }
        }
      }

      if (amount == null || amount <= 0) continue;

      var score = 100;

      if (upper.contains('TOTAL A PAGAR')) score += 90;
      if (upper.contains('NETO A PAGAR')) score += 85;
      if (upper.contains('IMPORTE A PAGAR')) score += 80;
      if (upper.contains('MONTO A PAGAR')) score += 75;
      if (upper.contains('IMPORTE TOTAL')) score += 80;
      if (upper.contains('MONTO TOTAL')) score += 70;
      if (upper.contains('TOTAL VENTA')) score += 60;
      if (upper.contains('TOTAL S/')) score += 50;
      if (RegExp(r'\bTOTAL\b').hasMatch(upper)) score += 30;
      if (amountLineIndex > i) score -= 8;

      // En comprobantes, el total suele estar más abajo.
      score += amountLineIndex;

      candidates.add(
        _AmountCandidate(
          value: amount,
          score: score,
          lineIndex: amountLineIndex,
          line: amountLineIndex == i ? line : lines[amountLineIndex],
        ),
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
      if (_looksLikeNoiseLine(upper) ||
          _looksLikeNegativeAmountLine(line) ||
          upper.contains('VUELTO') ||
          upper.contains('CAMBIO') ||
          upper.contains('EFECTIVO') ||
          upper.contains('TARJETA') ||
          upper.contains('PAGO CON') ||
          upper.contains('RECIBIDO') ||
          upper.contains('DESCUENTO') ||
          upper.contains('DSCTO') ||
          upper.contains('IGV') ||
          upper.contains('PROPINA') ||
          upper.contains('DONACION') ||
          upper.contains('DONACIÓN')) {
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
        upper.contains('NETO A PAGAR') ||
        upper.contains('IMPORTE A PAGAR') ||
        upper.contains('MONTO A PAGAR') ||
        upper.contains('IMPORTE TOTAL') ||
        upper.contains('MONTO TOTAL') ||
        upper.contains('TOTAL VENTA') ||
        upper.contains('TOTAL S/') ||
        RegExp(r'\bTOTAL\b').hasMatch(upper);
  }

  static bool _looksLikeNonTotalLine(String upper) {
    final blocked = [
      'SUBTOTAL',
      'SUB TOTAL',
      'TOTAL DESCUENTO',
      'TOTAL DSCTO',
      'TOTAL ITEMS',
      'TOTAL ÍTEMS',
      'TOTAL PRODUCTOS',
      'CANTIDAD TOTAL',
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
      'ISC',
    ];

    return blocked.any(upper.contains);
  }

  static bool _looksLikeNoiseLine(String upper) {
    final blocked = [
      'HTTP://',
      'HTTPS://',
      'WWW.',
      '.COM',
      '.PE',
      'PAPERLESS',
      'PORTAL',
      'CONSULTA',
      'CONSULTAR',
      'POLITICA',
      'POLÍTICA',
      'TERMINOS',
      'TÉRMINOS',
      'CAMBIOS',
      'REPRESENTACION IMPRESA',
      'REPRESENTACIÓN IMPRESA',
      'AUTORIZADO MEDIANTE',
      'HASH',
      'CODIGO QR',
      'CÓDIGO QR',
    ];

    return blocked.any(upper.contains);
  }

  static bool _looksLikeNegativeAmountLine(String line) {
    return RegExp(r'(^|\s)-\s*\d+[.,]\d{1,2}\b').hasMatch(line.trim());
  }

  // ---------------------------------------------------------------------------
  // Subtotal y tratamiento tributario
  // ---------------------------------------------------------------------------

  static _SubtotalExtraction _extractSubtotal(
    List<String> lines, {
    required double total,
    required double igv,
    required ExpenseTaxTreatment taxTreatment,
    required String upperText,
  }) {
    final explicitSubtotal = _extractExplicitSubtotal(lines);
    if (explicitSubtotal != null && explicitSubtotal >= 0) {
      return _SubtotalExtraction(
        value: _round2(explicitSubtotal),
        wasInferred: false,
      );
    }

    final operationBases = _extractOperationBases(lines);
    if (operationBases.isNotEmpty) {
      return _SubtotalExtraction(
        value: _round2(operationBases.reduce((a, b) => a + b)),
        wasInferred: false,
      );
    }

    if (total > 0 && igv > 0 && _canDeriveAmount(upperText)) {
      final derivedSubtotal = _round2(total - igv);
      if (derivedSubtotal > 0) {
        return _SubtotalExtraction(value: derivedSubtotal, wasInferred: true);
      }
    }

    if (total > 0 &&
        igv == 0 &&
        (taxTreatment == ExpenseTaxTreatment.exempt ||
            taxTreatment == ExpenseTaxTreatment.unaffected)) {
      return _SubtotalExtraction(value: total, wasInferred: true);
    }

    return const _SubtotalExtraction(value: 0.0, wasInferred: false);
  }

  static double? _extractExplicitSubtotal(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      final upper = lines[i].toUpperCase();
      if (!upper.contains('SUBTOTAL') && !upper.contains('SUB TOTAL')) {
        continue;
      }

      final amount = _firstAmountOnLineOrNext(lines, i);
      if (amount != null && amount >= 0) return amount;
    }

    return null;
  }

  static List<double> _extractOperationBases(List<String> lines) {
    final categorizedBases = <double>[];
    final fallbackBases = <double>[];

    for (final line in lines) {
      final upper = line.toUpperCase();
      if (_looksLikeNoiseLine(upper) || upper.contains('TOTAL')) continue;

      final amount =
          _firstDecimalAmountInLine(line) ?? _firstAmountInLine(line);
      if (amount == null || amount < 0) continue;

      final isCategorized =
          upper.contains('GRAVADA') ||
          upper.contains('GRAVADO') ||
          upper.contains('EXONERADA') ||
          upper.contains('EXONERADO') ||
          upper.contains('INAFECTA') ||
          upper.contains('INAFECTO');

      final isFallback =
          upper.contains('BASE IMPONIBLE') || upper.contains('VALOR VENTA');

      if (isCategorized) {
        categorizedBases.add(amount);
      } else if (isFallback) {
        fallbackBases.add(amount);
      }
    }

    return categorizedBases.isNotEmpty ? categorizedBases : fallbackBases;
  }

  static double? _extractTaxableBase(List<String> lines) {
    final gravadaBases = <double>[];
    final fallbackBases = <double>[];

    for (final line in lines) {
      final upper = line.toUpperCase();
      if (_looksLikeNoiseLine(upper) || upper.contains('TOTAL')) continue;

      final amount =
          _firstDecimalAmountInLine(line) ?? _firstAmountInLine(line);
      if (amount == null || amount < 0) continue;

      if (upper.contains('GRAVADA') || upper.contains('GRAVADO')) {
        gravadaBases.add(amount);
      } else if (upper.contains('BASE IMPONIBLE')) {
        fallbackBases.add(amount);
      }
    }

    final bases = gravadaBases.isNotEmpty ? gravadaBases : fallbackBases;
    if (bases.isEmpty) return null;

    return _round2(bases.reduce((a, b) => a + b));
  }

  static ExpenseTaxTreatment _extractTaxTreatment(
    List<String> lines,
    String upperText,
  ) {
    final hasExempt =
        upperText.contains('EXONERADA') || upperText.contains('EXONERADO');
    final hasUnaffected =
        upperText.contains('INAFECTA') || upperText.contains('INAFECTO');
    final hasTaxable =
        upperText.contains('GRAVADA') ||
        upperText.contains('GRAVADO') ||
        upperText.contains('BASE IMPONIBLE') ||
        _hasPositiveIgvEvidence(lines);

    if (hasTaxable && (hasExempt || hasUnaffected)) {
      return ExpenseTaxTreatment.mixed;
    }

    if (hasTaxable) return ExpenseTaxTreatment.taxable;
    if (hasExempt && hasUnaffected) return ExpenseTaxTreatment.mixed;
    if (hasExempt) return ExpenseTaxTreatment.exempt;
    if (hasUnaffected) return ExpenseTaxTreatment.unaffected;

    return ExpenseTaxTreatment.unknown;
  }

  static bool _hasPositiveIgvEvidence(List<String> lines) {
    for (final line in lines) {
      final upper = line.toUpperCase();
      if (!upper.contains('IGV') &&
          !upper.contains('I.G.V') &&
          !upper.contains('IMPUESTO GENERAL')) {
        continue;
      }

      final amount = _lastDecimalAmountInLine(line);
      if (amount != null && amount > 0) return true;
      if (upper.contains('18%')) return true;
    }

    return false;
  }

  static bool _canDeriveAmount(String upperText) {
    const blocked = [
      'DESCUENTO',
      'DSCTO',
      'PROPINA',
      'ISC',
      'ICBPER',
      'REDONDEO',
      'PERCEPCION',
      'PERCEPCIÓN',
      'RETENCION',
      'RETENCIÓN',
      'CARGO',
    ];

    return !blocked.any(upperText.contains);
  }

  // ---------------------------------------------------------------------------
  // IGV
  // ---------------------------------------------------------------------------

  static double _extractIgv(
    List<String> lines,
    double total,
    String upperText,
    ExpenseTaxTreatment taxTreatment,
    double? explicitIgv,
    double ratePercentage,
  ) {
    if (explicitIgv != null && explicitIgv >= 0) {
      return _round2(explicitIgv);
    }

    if (total <= 0) return 0.0;

    if (taxTreatment == ExpenseTaxTreatment.exempt ||
        taxTreatment == ExpenseTaxTreatment.unaffected ||
        taxTreatment == ExpenseTaxTreatment.mixed) {
      final taxableBase = _extractTaxableBase(lines);
      if (taxTreatment == ExpenseTaxTreatment.mixed && taxableBase != null) {
        return _round2(taxableBase * ratePercentage / 100);
      }

      return 0.0;
    }

    if (taxTreatment != ExpenseTaxTreatment.taxable ||
        !_canDeriveAmount(upperText)) {
      return 0.0;
    }

    final taxableBase = _extractTaxableBase(lines);
    if (taxableBase != null) {
      return _round2(taxableBase * ratePercentage / 100);
    }

    // Solo se infiere desde el total cuando el comprobante declara una operación gravada.
    final factor = ratePercentage / 100;
    return factor <= 0 ? 0 : _round2(total * factor / (1 + factor));
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

      final amount = _lastDecimalAmountInLine(line);
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

  // ---------------------------------------------------------------------------
  // Montos
  // ---------------------------------------------------------------------------

  static double? _firstAmountOnLineOrNext(List<String> lines, int index) {
    final line = lines[index];
    final amount = _firstDecimalAmountInLine(line) ?? _firstAmountInLine(line);
    if (amount != null) return amount;

    for (var offset = 1; offset <= 2; offset++) {
      final nextIndex = index + offset;
      if (nextIndex >= lines.length) break;

      final nextLine = lines[nextIndex];
      final nextUpper = nextLine.toUpperCase();
      if (_looksLikeNoiseLine(nextUpper) || _hasFinancialLabel(nextUpper)) {
        break;
      }

      final nextAmount =
          _firstDecimalAmountInLine(nextLine) ?? _firstAmountInLine(nextLine);
      if (nextAmount != null) return nextAmount;
    }

    return null;
  }

  static double? _firstAmountInLine(String line) {
    final matches = _amountRegex.allMatches(line).toList();
    for (final match in matches) {
      final amount = _parseAmount(match.group(1) ?? '');
      if (amount != null) return amount;
    }

    return null;
  }

  static double? _firstDecimalAmountInLine(String line) {
    final matches = _decimalAmountRegex.allMatches(line).toList();
    for (final match in matches) {
      final amount = _parseAmount(match.group(1) ?? '');
      if (amount != null) return amount;
    }

    return null;
  }

  static bool _hasFinancialLabel(String upper) {
    const labels = [
      'TOTAL',
      'SUBTOTAL',
      'SUB TOTAL',
      'IGV',
      'I.G.V',
      'GRAVADA',
      'GRAVADO',
      'EXONERADA',
      'EXONERADO',
      'INAFECTA',
      'INAFECTO',
      'DESCUENTO',
      'PROPINA',
    ];

    return labels.any(upper.contains);
  }

  static double? _lastAmountInLine(String line) {
    final matches = _amountRegex.allMatches(line).toList();
    if (matches.isEmpty) return null;

    for (final match in matches.reversed) {
      final amount = _parseAmount(match.group(1) ?? '');
      if (amount != null) return amount;
    }

    return null;
  }

  static double? _lastDecimalAmountInLine(String line) {
    final matches = _decimalAmountRegex.allMatches(line).toList();
    if (matches.isEmpty) return null;

    for (final match in matches.reversed) {
      final amount = _parseAmount(match.group(1) ?? '');
      if (amount != null) return amount;
    }

    return null;
  }

  static double? _parseAmount(String raw) {
    return MoneyUtils.parse(raw);
  }

  static double _round2(double value) {
    return MoneyUtils.round2(value);
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

class _SubtotalExtraction {
  final double value;
  final bool wasInferred;

  const _SubtotalExtraction({required this.value, required this.wasInferred});
}
