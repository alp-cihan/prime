// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider = OnboardingRepositoryProvider._();

final class OnboardingRepositoryProvider
    extends
        $FunctionalProvider<
          OnboardingRepository,
          OnboardingRepository,
          OnboardingRepository
        >
    with $Provider<OnboardingRepository> {
  OnboardingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnboardingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingRepository create(Ref ref) {
    return onboardingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingRepository>(value),
    );
  }
}

String _$onboardingRepositoryHash() =>
    r'49fa731c5e6628121c438bb400d83ed90f959f03';

@ProviderFor(createStarterQuestsUseCase)
final createStarterQuestsUseCaseProvider =
    CreateStarterQuestsUseCaseProvider._();

final class CreateStarterQuestsUseCaseProvider
    extends
        $FunctionalProvider<
          CreateStarterQuestsUseCase,
          CreateStarterQuestsUseCase,
          CreateStarterQuestsUseCase
        >
    with $Provider<CreateStarterQuestsUseCase> {
  CreateStarterQuestsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createStarterQuestsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createStarterQuestsUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateStarterQuestsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateStarterQuestsUseCase create(Ref ref) {
    return createStarterQuestsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateStarterQuestsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateStarterQuestsUseCase>(value),
    );
  }
}

String _$createStarterQuestsUseCaseHash() =>
    r'883c0d0db2f60993ee978c2db4f891bf1b7cbcc8';
