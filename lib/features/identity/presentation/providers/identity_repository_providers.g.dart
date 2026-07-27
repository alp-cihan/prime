// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(identityClock)
final identityClockProvider = IdentityClockProvider._();

final class IdentityClockProvider
    extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  IdentityClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityClockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return identityClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$identityClockHash() => r'94dd1356ef1afc6753d469e4b759cbf52cd8008b';

/// Composes the identity feature's single read-only service from
/// repositories/catalogs three OTHER features already own — this feature
/// introduces no repository or persisted state of its own (Phase 12: "Do
/// not introduce duplicated persistence").

@ProviderFor(identityService)
final identityServiceProvider = IdentityServiceProvider._();

/// Composes the identity feature's single read-only service from
/// repositories/catalogs three OTHER features already own — this feature
/// introduces no repository or persisted state of its own (Phase 12: "Do
/// not introduce duplicated persistence").

final class IdentityServiceProvider
    extends
        $FunctionalProvider<IdentityService, IdentityService, IdentityService>
    with $Provider<IdentityService> {
  /// Composes the identity feature's single read-only service from
  /// repositories/catalogs three OTHER features already own — this feature
  /// introduces no repository or persisted state of its own (Phase 12: "Do
  /// not introduce duplicated persistence").
  IdentityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityServiceHash();

  @$internal
  @override
  $ProviderElement<IdentityService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IdentityService create(Ref ref) {
    return identityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityService>(value),
    );
  }
}

String _$identityServiceHash() => r'a2d6ad9c61d9d477be13613d89734e639ff2a9b4';

@ProviderFor(loadIdentitySnapshotUseCase)
final loadIdentitySnapshotUseCaseProvider =
    LoadIdentitySnapshotUseCaseProvider._();

final class LoadIdentitySnapshotUseCaseProvider
    extends
        $FunctionalProvider<
          LoadIdentitySnapshotUseCase,
          LoadIdentitySnapshotUseCase,
          LoadIdentitySnapshotUseCase
        >
    with $Provider<LoadIdentitySnapshotUseCase> {
  LoadIdentitySnapshotUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadIdentitySnapshotUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadIdentitySnapshotUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadIdentitySnapshotUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadIdentitySnapshotUseCase create(Ref ref) {
    return loadIdentitySnapshotUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadIdentitySnapshotUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadIdentitySnapshotUseCase>(value),
    );
  }
}

String _$loadIdentitySnapshotUseCaseHash() =>
    r'aafe893986b1c34d50f10d1b2ac8c56ac37a2676';

@ProviderFor(loadRecentMilestonesUseCase)
final loadRecentMilestonesUseCaseProvider =
    LoadRecentMilestonesUseCaseProvider._();

final class LoadRecentMilestonesUseCaseProvider
    extends
        $FunctionalProvider<
          LoadRecentMilestonesUseCase,
          LoadRecentMilestonesUseCase,
          LoadRecentMilestonesUseCase
        >
    with $Provider<LoadRecentMilestonesUseCase> {
  LoadRecentMilestonesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadRecentMilestonesUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadRecentMilestonesUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadRecentMilestonesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadRecentMilestonesUseCase create(Ref ref) {
    return loadRecentMilestonesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadRecentMilestonesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadRecentMilestonesUseCase>(value),
    );
  }
}

String _$loadRecentMilestonesUseCaseHash() =>
    r'97a9851c71353d96e4538e5d06fa7222e1e9f17c';
