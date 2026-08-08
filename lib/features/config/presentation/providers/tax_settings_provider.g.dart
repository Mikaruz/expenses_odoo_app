// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Guarda el impuesto porcentual elegido. El cálculo usa 18% mientras Odoo no
/// tenga una selección inequívoca, pero nunca inventa un id de account.tax.

@ProviderFor(TaxSettingsNotifier)
final taxSettingsProvider = TaxSettingsNotifierProvider._();

/// Guarda el impuesto porcentual elegido. El cálculo usa 18% mientras Odoo no
/// tenga una selección inequívoca, pero nunca inventa un id de account.tax.
final class TaxSettingsNotifierProvider
    extends $NotifierProvider<TaxSettingsNotifier, TaxSettingsState> {
  /// Guarda el impuesto porcentual elegido. El cálculo usa 18% mientras Odoo no
  /// tenga una selección inequívoca, pero nunca inventa un id de account.tax.
  TaxSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxSettingsNotifierHash();

  @$internal
  @override
  TaxSettingsNotifier create() => TaxSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaxSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaxSettingsState>(value),
    );
  }
}

String _$taxSettingsNotifierHash() =>
    r'8316fbd11e60eff0b0447de84c0288998edbf629';

/// Guarda el impuesto porcentual elegido. El cálculo usa 18% mientras Odoo no
/// tenga una selección inequívoca, pero nunca inventa un id de account.tax.

abstract class _$TaxSettingsNotifier extends $Notifier<TaxSettingsState> {
  TaxSettingsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TaxSettingsState, TaxSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaxSettingsState, TaxSettingsState>,
              TaxSettingsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
