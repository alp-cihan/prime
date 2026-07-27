// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The built-in catalog, sorted by [Achievement.sortOrder] — declared here
/// (not in `achievement_query_providers.dart`, which depends on this file)
/// so [achievementEvaluationServiceProvider]/
/// [evaluateAndUnlockAchievementsUseCaseProvider] below can read the *same*
/// provider a test might override, rather than silently falling back to
/// the raw `achievementCatalog` constant regardless of any override. Every
/// other provider in this feature reads the catalog through here.

@ProviderFor(achievementCatalogList)
final achievementCatalogListProvider = AchievementCatalogListProvider._();

/// The built-in catalog, sorted by [Achievement.sortOrder] — declared here
/// (not in `achievement_query_providers.dart`, which depends on this file)
/// so [achievementEvaluationServiceProvider]/
/// [evaluateAndUnlockAchievementsUseCaseProvider] below can read the *same*
/// provider a test might override, rather than silently falling back to
/// the raw `achievementCatalog` constant regardless of any override. Every
/// other provider in this feature reads the catalog through here.

final class AchievementCatalogListProvider
    extends
        $FunctionalProvider<
          List<Achievement>,
          List<Achievement>,
          List<Achievement>
        >
    with $Provider<List<Achievement>> {
  /// The built-in catalog, sorted by [Achievement.sortOrder] — declared here
  /// (not in `achievement_query_providers.dart`, which depends on this file)
  /// so [achievementEvaluationServiceProvider]/
  /// [evaluateAndUnlockAchievementsUseCaseProvider] below can read the *same*
  /// provider a test might override, rather than silently falling back to
  /// the raw `achievementCatalog` constant regardless of any override. Every
  /// other provider in this feature reads the catalog through here.
  AchievementCatalogListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementCatalogListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementCatalogListHash();

  @$internal
  @override
  $ProviderElement<List<Achievement>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Achievement> create(Ref ref) {
    return achievementCatalogList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Achievement> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Achievement>>(value),
    );
  }
}

String _$achievementCatalogListHash() =>
    r'8e3feb0445adc8e069b263b5a93a4b2841f3ef34';

/// Singleton for the app's lifetime — wraps the already-open unlock box,
/// same pattern as `xpLedgerRepositoryProvider`.

@ProviderFor(achievementUnlockRepository)
final achievementUnlockRepositoryProvider =
    AchievementUnlockRepositoryProvider._();

/// Singleton for the app's lifetime — wraps the already-open unlock box,
/// same pattern as `xpLedgerRepositoryProvider`.

final class AchievementUnlockRepositoryProvider
    extends
        $FunctionalProvider<
          AchievementUnlockRepository,
          AchievementUnlockRepository,
          AchievementUnlockRepository
        >
    with $Provider<AchievementUnlockRepository> {
  /// Singleton for the app's lifetime — wraps the already-open unlock box,
  /// same pattern as `xpLedgerRepositoryProvider`.
  AchievementUnlockRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementUnlockRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementUnlockRepositoryHash();

  @$internal
  @override
  $ProviderElement<AchievementUnlockRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AchievementUnlockRepository create(Ref ref) {
    return achievementUnlockRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AchievementUnlockRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AchievementUnlockRepository>(value),
    );
  }
}

String _$achievementUnlockRepositoryHash() =>
    r'3d18b2437b1bde0a3c9816b0b7d12ff7bd50d040';

@ProviderFor(achievementEvaluationPolicy)
final achievementEvaluationPolicyProvider =
    AchievementEvaluationPolicyProvider._();

final class AchievementEvaluationPolicyProvider
    extends
        $FunctionalProvider<
          AchievementEvaluationPolicy,
          AchievementEvaluationPolicy,
          AchievementEvaluationPolicy
        >
    with $Provider<AchievementEvaluationPolicy> {
  AchievementEvaluationPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementEvaluationPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementEvaluationPolicyHash();

  @$internal
  @override
  $ProviderElement<AchievementEvaluationPolicy> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AchievementEvaluationPolicy create(Ref ref) {
    return achievementEvaluationPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AchievementEvaluationPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AchievementEvaluationPolicy>(value),
    );
  }
}

String _$achievementEvaluationPolicyHash() =>
    r'979ebe83cf7a7a3c3358d77fd6f1fcc61ac360aa';

@ProviderFor(achievementClock)
final achievementClockProvider = AchievementClockProvider._();

final class AchievementClockProvider
    extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  AchievementClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementClockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return achievementClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$achievementClockHash() => r'a5cf42fa317e7f52c00821c3a42686359ce2aa16';

@ProviderFor(achievementEvaluationService)
final achievementEvaluationServiceProvider =
    AchievementEvaluationServiceProvider._();

final class AchievementEvaluationServiceProvider
    extends
        $FunctionalProvider<
          AchievementEvaluationService,
          AchievementEvaluationService,
          AchievementEvaluationService
        >
    with $Provider<AchievementEvaluationService> {
  AchievementEvaluationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementEvaluationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementEvaluationServiceHash();

  @$internal
  @override
  $ProviderElement<AchievementEvaluationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AchievementEvaluationService create(Ref ref) {
    return achievementEvaluationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AchievementEvaluationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AchievementEvaluationService>(value),
    );
  }
}

String _$achievementEvaluationServiceHash() =>
    r'a096163b9e5cb7af0dbadedc2fb2a139773651ca';

@ProviderFor(evaluateAndUnlockAchievementsUseCase)
final evaluateAndUnlockAchievementsUseCaseProvider =
    EvaluateAndUnlockAchievementsUseCaseProvider._();

final class EvaluateAndUnlockAchievementsUseCaseProvider
    extends
        $FunctionalProvider<
          EvaluateAndUnlockAchievementsUseCase,
          EvaluateAndUnlockAchievementsUseCase,
          EvaluateAndUnlockAchievementsUseCase
        >
    with $Provider<EvaluateAndUnlockAchievementsUseCase> {
  EvaluateAndUnlockAchievementsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'evaluateAndUnlockAchievementsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$evaluateAndUnlockAchievementsUseCaseHash();

  @$internal
  @override
  $ProviderElement<EvaluateAndUnlockAchievementsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EvaluateAndUnlockAchievementsUseCase create(Ref ref) {
    return evaluateAndUnlockAchievementsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EvaluateAndUnlockAchievementsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EvaluateAndUnlockAchievementsUseCase>(value),
    );
  }
}

String _$evaluateAndUnlockAchievementsUseCaseHash() =>
    r'01ec7fae8cf143dc9bc094bc52b4c333a6be83c3';
