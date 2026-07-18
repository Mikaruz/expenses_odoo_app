// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forget_password_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ForgetPasswordForm)
final forgetPasswordFormProvider = ForgetPasswordFormProvider._();

final class ForgetPasswordFormProvider
    extends $NotifierProvider<ForgetPasswordForm, ForgetPasswordFormState> {
  ForgetPasswordFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgetPasswordFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgetPasswordFormHash();

  @$internal
  @override
  ForgetPasswordForm create() => ForgetPasswordForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgetPasswordFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgetPasswordFormState>(value),
    );
  }
}

String _$forgetPasswordFormHash() =>
    r'f548fe0b18d142a46a09b4e0ad444fd55b718f8b';

abstract class _$ForgetPasswordForm extends $Notifier<ForgetPasswordFormState> {
  ForgetPasswordFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ForgetPasswordFormState, ForgetPasswordFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ForgetPasswordFormState, ForgetPasswordFormState>,
              ForgetPasswordFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
