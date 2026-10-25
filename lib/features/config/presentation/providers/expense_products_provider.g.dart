// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExpenseProductsNotifier)
final expenseProductsProvider = ExpenseProductsNotifierProvider._();

final class ExpenseProductsNotifierProvider
    extends $NotifierProvider<ExpenseProductsNotifier, ExpenseProductsState> {
  ExpenseProductsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseProductsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseProductsNotifierHash();

  @$internal
  @override
  ExpenseProductsNotifier create() => ExpenseProductsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseProductsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseProductsState>(value),
    );
  }
}

String _$expenseProductsNotifierHash() =>
    r'9e6ac42d6c99b70b6bbcb3544c80705f7f07b9b9';

abstract class _$ExpenseProductsNotifier
    extends $Notifier<ExpenseProductsState> {
  ExpenseProductsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ExpenseProductsState, ExpenseProductsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExpenseProductsState, ExpenseProductsState>,
              ExpenseProductsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
