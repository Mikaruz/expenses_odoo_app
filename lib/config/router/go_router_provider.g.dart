// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_router_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goRouterNotifier)
final goRouterProvider = GoRouterNotifierProvider._();

final class GoRouterNotifierProvider
    extends
        $FunctionalProvider<
          GoRouterNotifier,
          GoRouterNotifier,
          GoRouterNotifier
        >
    with $Provider<GoRouterNotifier> {
  GoRouterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterNotifierHash();

  @$internal
  @override
  $ProviderElement<GoRouterNotifier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouterNotifier create(Ref ref) {
    return goRouterNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouterNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouterNotifier>(value),
    );
  }
}

String _$goRouterNotifierHash() => r'0d5bcf60012a83042e94f45f4f486c160043f341';
