// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The built-in catalog, sorted by [Chain.sortOrder] — declared here (not
/// in `chain_query_providers.dart`, which depends on this file) so
/// [evaluateAndAdvanceChainsUseCaseProvider] below can read the *same*
/// provider a test might override, rather than silently falling back to
/// the raw `chainCatalog` constant regardless of any override. Every other
/// provider in this file/feature reads the catalog through here.

@ProviderFor(chainCatalogList)
final chainCatalogListProvider = ChainCatalogListProvider._();

/// The built-in catalog, sorted by [Chain.sortOrder] — declared here (not
/// in `chain_query_providers.dart`, which depends on this file) so
/// [evaluateAndAdvanceChainsUseCaseProvider] below can read the *same*
/// provider a test might override, rather than silently falling back to
/// the raw `chainCatalog` constant regardless of any override. Every other
/// provider in this file/feature reads the catalog through here.

final class ChainCatalogListProvider
    extends $FunctionalProvider<List<Chain>, List<Chain>, List<Chain>>
    with $Provider<List<Chain>> {
  /// The built-in catalog, sorted by [Chain.sortOrder] — declared here (not
  /// in `chain_query_providers.dart`, which depends on this file) so
  /// [evaluateAndAdvanceChainsUseCaseProvider] below can read the *same*
  /// provider a test might override, rather than silently falling back to
  /// the raw `chainCatalog` constant regardless of any override. Every other
  /// provider in this file/feature reads the catalog through here.
  ChainCatalogListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chainCatalogListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chainCatalogListHash();

  @$internal
  @override
  $ProviderElement<List<Chain>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Chain> create(Ref ref) {
    return chainCatalogList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Chain> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Chain>>(value),
    );
  }
}

String _$chainCatalogListHash() => r'4dc1ba2aea03043bba17eb1b9967ab5ed373480f';

/// Singleton for the app's lifetime — wraps the already-open chain
/// progress box, same pattern as `achievementUnlockRepositoryProvider`.

@ProviderFor(chainProgressRepository)
final chainProgressRepositoryProvider = ChainProgressRepositoryProvider._();

/// Singleton for the app's lifetime — wraps the already-open chain
/// progress box, same pattern as `achievementUnlockRepositoryProvider`.

final class ChainProgressRepositoryProvider
    extends
        $FunctionalProvider<
          ChainProgressRepository,
          ChainProgressRepository,
          ChainProgressRepository
        >
    with $Provider<ChainProgressRepository> {
  /// Singleton for the app's lifetime — wraps the already-open chain
  /// progress box, same pattern as `achievementUnlockRepositoryProvider`.
  ChainProgressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chainProgressRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chainProgressRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChainProgressRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChainProgressRepository create(Ref ref) {
    return chainProgressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChainProgressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChainProgressRepository>(value),
    );
  }
}

String _$chainProgressRepositoryHash() =>
    r'8eae8b801bf6ab142bea872eb81ce0e07a862749';

@ProviderFor(chainProgressPolicy)
final chainProgressPolicyProvider = ChainProgressPolicyProvider._();

final class ChainProgressPolicyProvider
    extends
        $FunctionalProvider<
          ChainProgressPolicy,
          ChainProgressPolicy,
          ChainProgressPolicy
        >
    with $Provider<ChainProgressPolicy> {
  ChainProgressPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chainProgressPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chainProgressPolicyHash();

  @$internal
  @override
  $ProviderElement<ChainProgressPolicy> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChainProgressPolicy create(Ref ref) {
    return chainProgressPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChainProgressPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChainProgressPolicy>(value),
    );
  }
}

String _$chainProgressPolicyHash() =>
    r'8caf9222e46f72a1697f574a0aad404ada47de79';

@ProviderFor(chainClock)
final chainClockProvider = ChainClockProvider._();

final class ChainClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  ChainClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chainClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chainClockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return chainClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$chainClockHash() => r'5ec6cbd08210b05d5c492da54a3ec0b6c1541f67';

@ProviderFor(chainEvaluationService)
final chainEvaluationServiceProvider = ChainEvaluationServiceProvider._();

final class ChainEvaluationServiceProvider
    extends
        $FunctionalProvider<
          ChainEvaluationService,
          ChainEvaluationService,
          ChainEvaluationService
        >
    with $Provider<ChainEvaluationService> {
  ChainEvaluationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chainEvaluationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chainEvaluationServiceHash();

  @$internal
  @override
  $ProviderElement<ChainEvaluationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChainEvaluationService create(Ref ref) {
    return chainEvaluationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChainEvaluationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChainEvaluationService>(value),
    );
  }
}

String _$chainEvaluationServiceHash() =>
    r'c2ff046bb46aa7fda5fe74802610d3fed396f374';

@ProviderFor(evaluateAndAdvanceChainsUseCase)
final evaluateAndAdvanceChainsUseCaseProvider =
    EvaluateAndAdvanceChainsUseCaseProvider._();

final class EvaluateAndAdvanceChainsUseCaseProvider
    extends
        $FunctionalProvider<
          EvaluateAndAdvanceChainsUseCase,
          EvaluateAndAdvanceChainsUseCase,
          EvaluateAndAdvanceChainsUseCase
        >
    with $Provider<EvaluateAndAdvanceChainsUseCase> {
  EvaluateAndAdvanceChainsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'evaluateAndAdvanceChainsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$evaluateAndAdvanceChainsUseCaseHash();

  @$internal
  @override
  $ProviderElement<EvaluateAndAdvanceChainsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EvaluateAndAdvanceChainsUseCase create(Ref ref) {
    return evaluateAndAdvanceChainsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EvaluateAndAdvanceChainsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EvaluateAndAdvanceChainsUseCase>(
        value,
      ),
    );
  }
}

String _$evaluateAndAdvanceChainsUseCaseHash() =>
    r'c84fef229332a686c919dc730bf4519b66132941';
