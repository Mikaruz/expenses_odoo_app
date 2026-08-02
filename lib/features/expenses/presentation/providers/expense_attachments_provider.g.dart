// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_attachments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expenseAttachments)
final expenseAttachmentsProvider = ExpenseAttachmentsFamily._();

final class ExpenseAttachmentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExpenseAttachmentsState>,
          ExpenseAttachmentsState,
          FutureOr<ExpenseAttachmentsState>
        >
    with
        $FutureModifier<ExpenseAttachmentsState>,
        $FutureProvider<ExpenseAttachmentsState> {
  ExpenseAttachmentsProvider._({
    required ExpenseAttachmentsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'expenseAttachmentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expenseAttachmentsHash();

  @override
  String toString() {
    return r'expenseAttachmentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ExpenseAttachmentsState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExpenseAttachmentsState> create(Ref ref) {
    final argument = this.argument as int;
    return expenseAttachments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseAttachmentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expenseAttachmentsHash() =>
    r'7bf0fc9265015bfcde2c06c6c556b8f1b26bfe7c';

final class ExpenseAttachmentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ExpenseAttachmentsState>, int> {
  ExpenseAttachmentsFamily._()
    : super(
        retry: null,
        name: r'expenseAttachmentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpenseAttachmentsProvider call(int expenseId) =>
      ExpenseAttachmentsProvider._(argument: expenseId, from: this);

  @override
  String toString() => r'expenseAttachmentsProvider';
}
