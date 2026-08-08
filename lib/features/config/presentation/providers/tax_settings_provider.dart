import 'package:oh_expenses_app/features/config/domain/domain.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_settings_provider.g.dart';

class TaxSettingsState {
  static const defaultRatePercentage = 18.0;

  final int? taxId;
  final String? taxName;
  final double ratePercentage;

  const TaxSettingsState({
    this.taxId,
    this.taxName,
    this.ratePercentage = defaultRatePercentage,
  });
}

/// Guarda el impuesto porcentual elegido. El cálculo usa 18% mientras Odoo no
/// tenga una selección inequívoca, pero nunca inventa un id de account.tax.
@Riverpod(keepAlive: true)
class TaxSettingsNotifier extends _$TaxSettingsNotifier {
  static const _rateKey = 'selectedTaxRate';
  static const _idKey = 'selectedTaxId';
  static const _nameKey = 'selectedTaxName';

  late final KeyValueStorageService _storage;

  @override
  TaxSettingsState build() {
    _storage = KeyValueStorageServiceImpl();
    return const TaxSettingsState();
  }

  Future<void> load() async {
    final storedRate = await _storage.getValue<double>(_rateKey);
    final storedId = await _storage.getValue<int>(_idKey);
    final storedName = await _storage.getValue<String>(_nameKey);

    state = TaxSettingsState(
      taxId: storedId,
      taxName: storedName,
      ratePercentage: storedRate ?? TaxSettingsState.defaultRatePercentage,
    );
  }

  Future<void> setTax(ExpenseTax tax) async {
    if (!tax.supportsAutomaticCalculation) return;

    state = TaxSettingsState(
      taxId: tax.id,
      taxName: tax.name,
      ratePercentage: tax.ratePercentage,
    );
    await _storage.setKeyValue(_rateKey, tax.ratePercentage);
    await _storage.setKeyValue(_idKey, tax.id);
    await _storage.setKeyValue(_nameKey, tax.name);
  }

  Future<void> reconcileTaxes(List<ExpenseTax> taxes) async {
    final selected = taxes.where(
      (tax) => tax.id == state.taxId && tax.supportsAutomaticCalculation,
    );

    if (selected.isNotEmpty) {
      await setTax(selected.first);
      return;
    }

    final defaultTaxes = taxes.where(
      (tax) =>
          tax.supportsAutomaticCalculation &&
          (tax.ratePercentage - TaxSettingsState.defaultRatePercentage).abs() <
              0.001,
    );

    if (defaultTaxes.length == 1) {
      await setTax(defaultTaxes.first);
      return;
    }

    await clearSelection();
  }

  Future<void> clearSelection() async {
    state = const TaxSettingsState();
    await _storage.removeKey(_rateKey);
    await _storage.removeKey(_idKey);
    await _storage.removeKey(_nameKey);
  }
}
