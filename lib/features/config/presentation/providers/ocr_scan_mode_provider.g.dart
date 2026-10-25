// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_scan_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OcrScanModeNotifier)
final ocrScanModeProvider = OcrScanModeNotifierProvider._();

final class OcrScanModeNotifierProvider
    extends $NotifierProvider<OcrScanModeNotifier, OcrScanMode> {
  OcrScanModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ocrScanModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ocrScanModeNotifierHash();

  @$internal
  @override
  OcrScanModeNotifier create() => OcrScanModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OcrScanMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OcrScanMode>(value),
    );
  }
}

String _$ocrScanModeNotifierHash() =>
    r'5788b45fdbf9350bd031512223d1cafe6039b36e';

abstract class _$OcrScanModeNotifier extends $Notifier<OcrScanMode> {
  OcrScanMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OcrScanMode, OcrScanMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OcrScanMode, OcrScanMode>,
              OcrScanMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
