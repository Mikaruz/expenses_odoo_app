import 'package:oh_expenses_app/features/auth/auth.dart';
import 'package:oh_expenses_app/features/config/domain/domain.dart';
import 'package:oh_expenses_app/features/config/infrastructure/infrastructure.dart';
import 'package:oh_expenses_app/features/config/presentation/providers/tax_settings_provider.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'taxes_provider.g.dart';

class TaxesState {
  final bool isLoading;
  final bool hasLoaded;
  final List<ExpenseTax> taxes;
  final String errorMessage;

  const TaxesState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.taxes = const [],
    this.errorMessage = '',
  });

  TaxesState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    List<ExpenseTax>? taxes,
    String? errorMessage,
  }) {
    return TaxesState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      taxes: taxes ?? this.taxes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class TaxesNotifier extends _$TaxesNotifier {
  late final TaxRepository _repository = TaxRepositoryImpl(TaxDatasourceImpl());
  late final KeyValueStorageService _storage;

  @override
  TaxesState build() {
    _storage = KeyValueStorageServiceImpl();
    return const TaxesState();
  }

  Future<void> loadTaxes() async {
    if (state.isLoading) return;

    final authState = ref.read(authProvider);
    final user = authState.user;

    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Inicia sesión para consultar los impuestos.',
      );
      return;
    }

    final odooUrl = await _storage.getValue<String>('odooUrl');
    final database = await _storage.getValue<String>('odooDatabase');

    if (odooUrl == null || database == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Faltan datos de conexión para consultar Odoo.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final taxes = await _repository.getTaxes(
        odooUrl: odooUrl,
        database: database,
        sessionId: user.sessionId,
      );

      await ref.read(taxSettingsProvider.notifier).reconcileTaxes(taxes);

      state = state.copyWith(isLoading: false, hasLoaded: true, taxes: taxes);
    } on CustomError catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: 'Error inesperado consultando impuestos.',
      );
    }
  }
}
