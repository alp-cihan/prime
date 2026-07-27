// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_query_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits the current progress list immediately, then again on every
/// subsequent change (`HiveChainProgressRepository.watchAll`'s
/// `Box.watch()`-backed contract).

@ProviderFor(watchAllChainProgress)
final watchAllChainProgressProvider = WatchAllChainProgressProvider._();

/// Emits the current progress list immediately, then again on every
/// subsequent change (`HiveChainProgressRepository.watchAll`'s
/// `Box.watch()`-backed contract).

final class WatchAllChainProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChainProgress>>,
          List<ChainProgress>,
          Stream<List<ChainProgress>>
        >
    with
        $FutureModifier<List<ChainProgress>>,
        $StreamProvider<List<ChainProgress>> {
  /// Emits the current progress list immediately, then again on every
  /// subsequent change (`HiveChainProgressRepository.watchAll`'s
  /// `Box.watch()`-backed contract).
  WatchAllChainProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAllChainProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAllChainProgressHash();

  @$internal
  @override
  $StreamProviderElement<List<ChainProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ChainProgress>> create(Ref ref) {
    return watchAllChainProgress(ref);
  }
}

String _$watchAllChainProgressHash() =>
    r'92a08b047a79a05a4f464a5e771e4929c87524fe';

/// Every catalog chain paired with its derived progress — the single
/// composition point every other provider in this file derives from, so
/// there is exactly one place that turns "a chain + its stored progress
/// row" into the full view model.

@ProviderFor(allChainsWithProgress)
final allChainsWithProgressProvider = AllChainsWithProgressProvider._();

/// Every catalog chain paired with its derived progress — the single
/// composition point every other provider in this file derives from, so
/// there is exactly one place that turns "a chain + its stored progress
/// row" into the full view model.

final class AllChainsWithProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChainWithProgress>>,
          List<ChainWithProgress>,
          FutureOr<List<ChainWithProgress>>
        >
    with
        $FutureModifier<List<ChainWithProgress>>,
        $FutureProvider<List<ChainWithProgress>> {
  /// Every catalog chain paired with its derived progress — the single
  /// composition point every other provider in this file derives from, so
  /// there is exactly one place that turns "a chain + its stored progress
  /// row" into the full view model.
  AllChainsWithProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allChainsWithProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allChainsWithProgressHash();

  @$internal
  @override
  $FutureProviderElement<List<ChainWithProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChainWithProgress>> create(Ref ref) {
    return allChainsWithProgress(ref);
  }
}

String _$allChainsWithProgressHash() =>
    r'1d87fae7459ed3d33aa784fc81af562632ff2551';

/// Chains not yet completed — the Chains page's "Active" section.

@ProviderFor(activeChains)
final activeChainsProvider = ActiveChainsProvider._();

/// Chains not yet completed — the Chains page's "Active" section.

final class ActiveChainsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChainWithProgress>>,
          List<ChainWithProgress>,
          FutureOr<List<ChainWithProgress>>
        >
    with
        $FutureModifier<List<ChainWithProgress>>,
        $FutureProvider<List<ChainWithProgress>> {
  /// Chains not yet completed — the Chains page's "Active" section.
  ActiveChainsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeChainsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeChainsHash();

  @$internal
  @override
  $FutureProviderElement<List<ChainWithProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChainWithProgress>> create(Ref ref) {
    return activeChains(ref);
  }
}

String _$activeChainsHash() => r'1f4989845413e81333569cc45d43ce830643cfb0';

/// Chains fully completed — the Chains page's "Completed" section.

@ProviderFor(completedChains)
final completedChainsProvider = CompletedChainsProvider._();

/// Chains fully completed — the Chains page's "Completed" section.

final class CompletedChainsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChainWithProgress>>,
          List<ChainWithProgress>,
          FutureOr<List<ChainWithProgress>>
        >
    with
        $FutureModifier<List<ChainWithProgress>>,
        $FutureProvider<List<ChainWithProgress>> {
  /// Chains fully completed — the Chains page's "Completed" section.
  CompletedChainsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedChainsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedChainsHash();

  @$internal
  @override
  $FutureProviderElement<List<ChainWithProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChainWithProgress>> create(Ref ref) {
    return completedChains(ref);
  }
}

String _$completedChainsHash() => r'08e3d5ae3c4eb89f98be56ea3656f7c4f3b0642c';

/// One chain's full view, for the Chain Detail page — `null` if [chainId]
/// isn't in the catalog.

@ProviderFor(chainDetail)
final chainDetailProvider = ChainDetailFamily._();

/// One chain's full view, for the Chain Detail page — `null` if [chainId]
/// isn't in the catalog.

final class ChainDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChainWithProgress?>,
          ChainWithProgress?,
          FutureOr<ChainWithProgress?>
        >
    with
        $FutureModifier<ChainWithProgress?>,
        $FutureProvider<ChainWithProgress?> {
  /// One chain's full view, for the Chain Detail page — `null` if [chainId]
  /// isn't in the catalog.
  ChainDetailProvider._({
    required ChainDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chainDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chainDetailHash();

  @override
  String toString() {
    return r'chainDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChainWithProgress?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChainWithProgress?> create(Ref ref) {
    final argument = this.argument as String;
    return chainDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChainDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chainDetailHash() => r'e32ee3e00c6f923d176523cea31d907dd22e864c';

/// One chain's full view, for the Chain Detail page — `null` if [chainId]
/// isn't in the catalog.

final class ChainDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChainWithProgress?>, String> {
  ChainDetailFamily._()
    : super(
        retry: null,
        name: r'chainDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One chain's full view, for the Chain Detail page — `null` if [chainId]
  /// isn't in the catalog.

  ChainDetailProvider call(String chainId) =>
      ChainDetailProvider._(argument: chainId, from: this);

  @override
  String toString() => r'chainDetailProvider';
}

/// Just the current stage for one chain — `null` once it's completed (or
/// if [chainId] isn't in the catalog).

@ProviderFor(currentChainStage)
final currentChainStageProvider = CurrentChainStageFamily._();

/// Just the current stage for one chain — `null` once it's completed (or
/// if [chainId] isn't in the catalog).

final class CurrentChainStageProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChainStage?>,
          ChainStage?,
          FutureOr<ChainStage?>
        >
    with $FutureModifier<ChainStage?>, $FutureProvider<ChainStage?> {
  /// Just the current stage for one chain — `null` once it's completed (or
  /// if [chainId] isn't in the catalog).
  CurrentChainStageProvider._({
    required CurrentChainStageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'currentChainStageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentChainStageHash();

  @override
  String toString() {
    return r'currentChainStageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChainStage?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChainStage?> create(Ref ref) {
    final argument = this.argument as String;
    return currentChainStage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentChainStageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentChainStageHash() => r'686b167f29f55fd35556f2105c2bbb2cfffe22c9';

/// Just the current stage for one chain — `null` once it's completed (or
/// if [chainId] isn't in the catalog).

final class CurrentChainStageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChainStage?>, String> {
  CurrentChainStageFamily._()
    : super(
        retry: null,
        name: r'currentChainStageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Just the current stage for one chain — `null` once it's completed (or
  /// if [chainId] isn't in the catalog).

  CurrentChainStageProvider call(String chainId) =>
      CurrentChainStageProvider._(argument: chainId, from: this);

  @override
  String toString() => r'currentChainStageProvider';
}
