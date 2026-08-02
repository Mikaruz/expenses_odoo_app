// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExpensesNotifier)
final expensesProvider = ExpensesNotifierProvider._();

final class ExpensesNotifierProvider
    extends $NotifierProvider<ExpensesNotifier, ExpensesState> {
  ExpensesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expensesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expensesNotifierHash();

  @$internal
  @override
  ExpensesNotifier create() => ExpensesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpensesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpensesState>(value),
    );
  }
}

String _$expensesNotifierHash() => r'db4f217ee81a72b7431f0cc785d12d574c9f6fe7';

abstract class _$ExpensesNotifier extends $Notifier<ExpensesState> {
  ExpensesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ExpensesState, ExpensesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExpensesState, ExpensesState>,
              ExpensesState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
