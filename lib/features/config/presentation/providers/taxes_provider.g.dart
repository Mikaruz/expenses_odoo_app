// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaxesNotifier)
final taxesProvider = TaxesNotifierProvider._();

final class TaxesNotifierProvider
    extends $NotifierProvider<TaxesNotifier, TaxesState> {
  TaxesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxesNotifierHash();

  @$internal
  @override
  TaxesNotifier create() => TaxesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaxesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaxesState>(value),
    );
  }
}

String _$taxesNotifierHash() => r'5d9f56a365f6e61cb500193185a36e32d56137a9';

abstract class _$TaxesNotifier extends $Notifier<TaxesState> {
  TaxesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TaxesState, TaxesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaxesState, TaxesState>,
              TaxesState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
