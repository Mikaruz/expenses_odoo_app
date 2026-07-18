import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/expenses/infrastructure/infrastructure.dart';

import 'package:oh_expenses_app/features/expenses/utils/ocr_parser.dart';

part 'ocr_provider.g.dart';

class OcrState {
  final bool isLoading;
  final String? error;
  final OcrExpenseResult? result;
  final String? imagePath;

  const OcrState({
    this.isLoading = false,
    this.error,
    this.result,
    this.imagePath,
  });

  OcrState copyWith({
    bool? isLoading,
    String? error,
    OcrExpenseResult? result,
    String? imagePath,
  }) {
    return OcrState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be set to null
      result: result, // Can be set to null
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

@riverpod
class OcrNotifier extends _$OcrNotifier {
  late final _expenseRepository = ExpensesRepositoryImpl(
    ExpensesDatasourceImpl(),
  );

  @override
  OcrState build() {
    return const OcrState();
  }

  void reset() {
    state = const OcrState();
  }

  Future<String?> pickImage(ImageSource source) async {
    return await _expenseRepository.pickImage(source);
  }

  Future<bool> processImagePath(String imagePath) async {
    Logger.info('Iniciando Provider processImagePath...');
    // Conservamos la ruta de la imagen en el estado mientras carga
    state = state.copyWith(
      isLoading: true,
      error: null,
      result: null,
      imagePath: imagePath,
    );

    try {
      final text = await _expenseRepository.processImagePath(imagePath);
      Logger.info('Provider: Texto detectado por OCR:\n$text');

      if (text == null || text.trim().isEmpty) {
        Logger.warning('Provider: No se detectó texto.');
        state = state.copyWith(
          isLoading: false,
          error: 'No se detectó texto en la imagen.',
        );

        return false;
      }

      final result = OcrParser.parse(text);

      // Basic validation to check if we found any important field
      if (result.ruc.isEmpty && result.date.isEmpty && result.total == 0.0) {
        Logger.warning('Provider: No se detectaron campos importantes.');
        state = state.copyWith(
          isLoading: false,
          error:
              'No se detectaron campos importantes. Por favor, ingrese los datos manualmente.',
          result: result,
        );
        return true;
      }

      Logger.success(
        'Provider: Parseo exitoso. Total detectado: ${result.total}',
      );
      state = state.copyWith(
        isLoading: false,
        result: result,
        imagePath: imagePath,
      );
      return true;
    } catch (e) {
      Logger.error('Provider: Error capturado - $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error procesando imagen: $e',
      );
      return false;
    }
  }
}
