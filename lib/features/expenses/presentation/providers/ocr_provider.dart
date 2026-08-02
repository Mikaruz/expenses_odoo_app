import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/infrastructure.dart';

import 'package:oh_expenses_app/features/expenses/utils/expense_amount_validator.dart';
import 'package:oh_expenses_app/features/expenses/utils/ocr_parser.dart';

part 'ocr_provider.g.dart';

class OcrState {
  final bool isLoading;
  final bool isBlocked;
  final String? error;
  final List<String> warnings;
  final OcrExpenseResult? result;
  final String? imagePath;

  const OcrState({
    this.isLoading = false,
    this.isBlocked = false,
    this.error,
    this.warnings = const [],
    this.result,
    this.imagePath,
  });

  OcrState copyWith({
    bool? isLoading,
    bool? isBlocked,
    String? error,
    List<String>? warnings,
    OcrExpenseResult? result,
    String? imagePath,
  }) {
    return OcrState(
      isLoading: isLoading ?? this.isLoading,
      isBlocked: isBlocked ?? this.isBlocked,
      error: error,
      warnings: warnings ?? this.warnings,
      result: result,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

@Riverpod(keepAlive: true)
class OcrNotifier extends _$OcrNotifier {
  late final _expenseRepository = ExpensesRepositoryImpl(
    ExpensesDatasourceImpl(),
  );

  @override
  OcrState build() {
    return const OcrState();
  }

  void reset() {
    if (!ref.mounted) return;
    state = const OcrState();
  }

  Future<String?> pickImage(ImageSource source) async {
    return await _expenseRepository.pickImage(source);
  }

  Future<bool> processImagePath(String imagePath) async {
    Logger.info('Iniciando Provider processImagePath...');
    // Conservamos la ruta de la imagen en el estado mientras carga
    if (!ref.mounted) return false;
    state = state.copyWith(
      isLoading: true,
      isBlocked: false,
      error: null,
      warnings: const [],
      result: null,
      imagePath: imagePath,
    );

    try {
      final text = await _expenseRepository.processImagePath(imagePath);
      if (!ref.mounted) return false;

      Logger.info('Provider: Texto detectado por OCR:\n$text');

      if (text == null || text.trim().isEmpty) {
        Logger.warning('Provider: No se detectó texto.');
        state = state.copyWith(
          isLoading: false,
          isBlocked: true,
          error:
              'No se pudo leer la imagen. Toma una fotografía más nítida, '
              'completa y con buena iluminación.',
          warnings: const [],
        );

        return false;
      }

      final result = OcrParser.parse(text);
      if (!ref.mounted) return false;

      if (!_hasExpenseEvidence(result)) {
        Logger.warning('Provider: No se detectó ningún comprobante de gasto.');
        state = state.copyWith(
          isLoading: false,
          isBlocked: true,
          error:
              'No se detectó ningún comprobante de gasto en la imagen. '
              'Usa una foto de una boleta, factura o ticket.',
          result: result,
          warnings: const [],
        );
        return false;
      }

      final warnings = _buildWarnings(result);

      Logger.success(
        'Provider: Parseo exitoso. Total detectado: ${result.total}',
      );
      state = state.copyWith(
        isLoading: false,
        isBlocked: false,
        error: null,
        warnings: warnings,
        result: result,
        imagePath: imagePath,
      );
      return true;
    } catch (e) {
      Logger.error('Provider: Error capturado - $e');
      if (!ref.mounted) return false;

      state = state.copyWith(
        isLoading: false,
        isBlocked: true,
        error: 'Error procesando imagen: $e',
        warnings: const [],
      );
      return false;
    }
  }

  bool _hasExpenseEvidence(OcrExpenseResult result) {
    final hasAmount = result.total > 0 || result.subtotal > 0 || result.igv > 0;
    final upperText = result.rawText.toUpperCase();
    final hasReceiptMarker = RegExp(
      r'\b(FACTURA|BOLETA|TICKET|RECIBO|COMPROBANTE|RUC|TOTAL|SUBTOTAL|'
      r'IGV|GRAVADA|GRAVADO|EXONERADA|EXONERADO|INAFECTA|INAFECTO)\b',
    ).hasMatch(upperText);
    final identitySignals = [
      result.ruc,
      result.type,
      result.serialNumber,
    ].where((value) => value.isNotEmpty).length;

    return (hasAmount && hasReceiptMarker) || identitySignals >= 2;
  }

  List<String> _buildWarnings(OcrExpenseResult result) {
    final warnings = <String>[];

    if (result.igvWasInferred) {
      warnings.add(
        'El IGV fue estimado usando la tasa usual del 18%. Confirma el importe.',
      );
    }

    if (result.subtotalWasInferred) {
      warnings.add(
        'El subtotal fue calculado a partir de otros montos. Confirma que no '
        'existan descuentos, propinas u otros cargos.',
      );
    }

    if (result.taxTreatment == ExpenseTaxTreatment.exempt ||
        result.taxTreatment == ExpenseTaxTreatment.unaffected) {
      warnings.add(
        'El comprobante parece exonerado o inafecto. Se considera IGV S/ 0.00; '
        'confirma el valor.',
      );
    } else if (result.taxTreatment == ExpenseTaxTreatment.mixed) {
      warnings.add(
        'Se detectaron operaciones gravadas y no gravadas. El 18% aplica '
        'únicamente sobre la base gravada; revisa el subtotal.',
      );
    }

    if (result.subtotal <= 0 || result.total <= 0) {
      warnings.add(
        'Se detectó un comprobante parcialmente. Completa o revisa subtotal, '
        'IGV y total.',
      );
    } else {
      final validation = ExpenseAmountValidator.validate(
        subtotal: result.subtotal,
        igv: result.igv,
        total: result.total,
        taxTreatment: result.taxTreatment,
      );

      if (!validation.isValid && validation.errorMessage != null) {
        warnings.add(validation.errorMessage!);
      }
    }

    return warnings;
  }
}
