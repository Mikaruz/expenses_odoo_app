// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expensesDatabase)
final expensesDatabaseProvider = ExpensesDatabaseProvider._();

final class ExpensesDatabaseProvider
    extends
        $FunctionalProvider<
          ExpensesDatabase,
          ExpensesDatabase,
          ExpensesDatabase
        >
    with $Provider<ExpensesDatabase> {
  ExpensesDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expensesDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expensesDatabaseHash();

  @$internal
  @override
  $ProviderElement<ExpensesDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExpensesDatabase create(Ref ref) {
    return expensesDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpensesDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpensesDatabase>(value),
    );
  }
}

String _$expensesDatabaseHash() => r'786fe4a9552f3cc8ec7725e50e8cf6e46276f79c';

@ProviderFor(localExpensesRepository)
final localExpensesRepositoryProvider = LocalExpensesRepositoryProvider._();

final class LocalExpensesRepositoryProvider
    extends
        $FunctionalProvider<
          LocalExpensesRepository,
          LocalExpensesRepository,
          LocalExpensesRepository
        >
    with $Provider<LocalExpensesRepository> {
  LocalExpensesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localExpensesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localExpensesRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocalExpensesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalExpensesRepository create(Ref ref) {
    return localExpensesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalExpensesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalExpensesRepository>(value),
    );
  }
}

String _$localExpensesRepositoryHash() =>
    r'e0b0c415b5b5af28199c3c60cdd0611d9162d041';

@ProviderFor(remoteExpensesRepository)
final remoteExpensesRepositoryProvider = RemoteExpensesRepositoryProvider._();

final class RemoteExpensesRepositoryProvider
    extends
        $FunctionalProvider<
          ExpensesRepository,
          ExpensesRepository,
          ExpensesRepository
        >
    with $Provider<ExpensesRepository> {
  RemoteExpensesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteExpensesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteExpensesRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExpensesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExpensesRepository create(Ref ref) {
    return remoteExpensesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpensesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpensesRepository>(value),
    );
  }
}

String _$remoteExpensesRepositoryHash() =>
    r'146af4d4419ed094fcb054f4abef8633e3abf1de';

@ProviderFor(currentAccountScope)
final currentAccountScopeProvider = CurrentAccountScopeProvider._();

final class CurrentAccountScopeProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  CurrentAccountScopeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAccountScopeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAccountScopeHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentAccountScope(ref);
  }
}

String _$currentAccountScopeHash() =>
    r'54ce0dbf343a3b7a8984df03eb0a44f1d37b4dc8';

@ProviderFor(expenses)
final expensesProvider = ExpensesProvider._();

final class ExpensesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LocalExpense>>,
          List<LocalExpense>,
          Stream<List<LocalExpense>>
        >
    with
        $FutureModifier<List<LocalExpense>>,
        $StreamProvider<List<LocalExpense>> {
  ExpensesProvider._()
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
  String debugGetCreateSourceHash() => _$expensesHash();

  @$internal
  @override
  $StreamProviderElement<List<LocalExpense>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LocalExpense>> create(Ref ref) {
    return expenses(ref);
  }
}

String _$expensesHash() => r'9757f076f725c5b7421cbc222537020e3f6d36b1';

@ProviderFor(receiptPath)
final receiptPathProvider = ReceiptPathFamily._();

final class ReceiptPathProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  ReceiptPathProvider._({
    required ReceiptPathFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'receiptPathProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$receiptPathHash();

  @override
  String toString() {
    return r'receiptPathProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return receiptPath(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceiptPathProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$receiptPathHash() => r'79aa091a8741d264224804400213876c3a2dda3e';

final class ReceiptPathFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  ReceiptPathFamily._()
    : super(
        retry: null,
        name: r'receiptPathProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReceiptPathProvider call(String relativePath) =>
      ReceiptPathProvider._(argument: relativePath, from: this);

  @override
  String toString() => r'receiptPathProvider';
}

@ProviderFor(ExpenseSyncNotifier)
final expenseSyncProvider = ExpenseSyncNotifierProvider._();

final class ExpenseSyncNotifierProvider
    extends $NotifierProvider<ExpenseSyncNotifier, ExpenseSyncState> {
  ExpenseSyncNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseSyncNotifierHash();

  @$internal
  @override
  ExpenseSyncNotifier create() => ExpenseSyncNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseSyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseSyncState>(value),
    );
  }
}

String _$expenseSyncNotifierHash() =>
    r'4e3cc4107dd12bc128be027bf074059ea8b0cc95';

abstract class _$ExpenseSyncNotifier extends $Notifier<ExpenseSyncState> {
  ExpenseSyncState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ExpenseSyncState, ExpenseSyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExpenseSyncState, ExpenseSyncState>,
              ExpenseSyncState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
