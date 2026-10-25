import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:oh_expenses_app/features/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/infrastructure.dart';

import 'package:oh_expenses_app/features/expenses/utils/expense_amount_validator.dart';
import 'package:oh_expenses_app/features/expenses/utils/ocr_parser.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

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
  late final _remoteOcrDatasource = ExpenseOcrDatasourceImpl();
  late final _storage = KeyValueStorageServiceImpl();

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
      final remoteResult = await _tryRemoteOcr(imagePath);
      if (remoteResult != null) {
        return _publishResult(remoteResult, imagePath);
      }

      final text = await _expenseRepository.processImagePath(imagePath);
      if (!ref.mounted) return false;

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

      await ref.read(taxSettingsProvider.notifier).load();
      final ratePercentage = ref.read(taxSettingsProvider).ratePercentage;
      final result = OcrParser.parse(text, ratePercentage: ratePercentage);
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

      return _publishResult(result, imagePath, ratePercentage: ratePercentage);
    } on ExpenseOcrRemoteException catch (e) {
      Logger.error('Provider: Error del OCR remoto - ${e.message}');
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        isBlocked: true,
        error: e.message,
        warnings: const [],
      );
      return false;
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

  Future<OcrExpenseResult?> _tryRemoteOcr(String imagePath) async {
    final scanModeNotifier = ref.read(ocrScanModeProvider.notifier);
    await scanModeNotifier.load();
    final scanMode = ref.read(ocrScanModeProvider);
    if (scanMode == OcrScanMode.device) {
      Logger.info('OCR remoto omitido: modo Dispositivo seleccionado.');
      return null;
    }

    await ref.read(authProvider.notifier).ensureOnlineSession();
    final authState = ref.read(authProvider);
    final authentication = authState.user;
    if (authState.isOffline ||
        authentication == null ||
        authentication.sessionId.trim().isEmpty) {
      if (scanMode == OcrScanMode.odoo) {
        final message = authState.errorMessage.isNotEmpty
            ? authState.errorMessage
            : 'El modo Servidor Odoo requiere una sesión activa y conexión con Odoo.';
        throw ExpenseOcrRemoteException(message);
      }
      Logger.info('OCR remoto omitido: no existe una sesión Odoo activa.');
      return null;
    }

    final odooUrl = await _storage.getValue<String>('odooUrl');
    final database = await _storage.getValue<String>('odooDatabase');
    if (odooUrl == null || database == null || odooUrl.trim().isEmpty) {
      if (scanMode == OcrScanMode.odoo) {
        throw const ExpenseOcrRemoteException(
          'El modo Servidor Odoo requiere configurar la conexión con Odoo.',
        );
      }
      Logger.info('OCR remoto omitido: falta configuración de Odoo.');
      return null;
    }

    try {
      Logger.info('Enviando comprobante al OCR de Odoo...');
      final result = await _remoteOcrDatasource.processImage(
        imagePath: imagePath,
        odooUrl: odooUrl,
        database: database,
        sessionId: authentication.sessionId,
      );
      Logger.success('OCR de Odoo completado. Total: ${result.total}');
      return result;
    } on ExpenseOcrRemoteException catch (error) {
      if (error.isConnectivityFailure && scanMode == OcrScanMode.automatic) {
        Logger.warning(
          'OCR de Odoo no disponible; se usará OCR local: ${error.message}',
        );
        return null;
      }
      rethrow;
    }
  }

  bool _publishResult(
    OcrExpenseResult result,
    String imagePath, {
    double? ratePercentage,
  }) {
    if (!ref.mounted) return false;

    final hasEvidence = _hasExpenseEvidence(result);
    final serverBlocked =
        result.isRemote && result.validationStatus == 'invalid';
    if (!hasEvidence || serverBlocked) {
      final message = result.validationMessages.isNotEmpty
          ? result.validationMessages.join('\n')
          : 'No se detectó ningún comprobante de gasto en la imagen.';
      state = state.copyWith(
        isLoading: false,
        isBlocked: true,
        error: message,
        warnings: result.validationMessages,
        result: result,
        imagePath: imagePath,
      );
      return false;
    }

    final warnings = result.validationMessages.isNotEmpty
        ? result.validationMessages
        : _buildWarnings(
            result,
            ratePercentage ?? ref.read(taxSettingsProvider).ratePercentage,
          );
    Logger.success('Parseo OCR exitoso. Total detectado: ${result.total}');
    state = state.copyWith(
      isLoading: false,
      isBlocked: false,
      error: null,
      warnings: warnings,
      result: result,
      imagePath: imagePath,
    );
    return true;
  }

  bool _hasExpenseEvidence(OcrExpenseResult result) {
    final hasAmount = result.total > 0 || result.subtotal > 0 || result.igv > 0;
    if (result.isRemote) {
      final identitySignals = [
        result.ruc,
        result.type,
        result.serialNumber,
      ].where((value) => value.isNotEmpty).length;
      return hasAmount && identitySignals >= 1;
    }
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

  List<String> _buildWarnings(OcrExpenseResult result, double ratePercentage) {
    final warnings = <String>[];

    if (result.igvWasInferred) {
      warnings.add(
        'El impuesto fue calculado desde el total usando una tasa de '
        '${ratePercentage.toStringAsFixed(2)}%. Confirma el importe.',
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
        'Se detectaron operaciones gravadas y no gravadas. La tasa aplica '
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
        ratePercentage: ratePercentage,
      );

      if (!validation.isValid && validation.errorMessage != null) {
        warnings.add(validation.errorMessage!);
      }
    }

    return warnings;
  }
}
