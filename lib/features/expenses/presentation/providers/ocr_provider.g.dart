// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OcrNotifier)
final ocrProvider = OcrNotifierProvider._();

final class OcrNotifierProvider
    extends $NotifierProvider<OcrNotifier, OcrState> {
  OcrNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ocrProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ocrNotifierHash();

  @$internal
  @override
  OcrNotifier create() => OcrNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OcrState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OcrState>(value),
    );
  }
}

String _$ocrNotifierHash() => r'558298ad0d131ffdb45c91c4979a48b74d5420b1';

abstract class _$OcrNotifier extends $Notifier<OcrState> {
  OcrState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OcrState, OcrState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OcrState, OcrState>,
              OcrState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
