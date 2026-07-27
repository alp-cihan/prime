// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_query_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Identity page's single source snapshot — reactive to every event
/// that can change it without needing its own evaluation controller (this
/// feature has no write side to trigger from): [totalXpProvider] is
/// already invalidated by `CompleteQuestController` after every quest
/// completion (Phase 6), and the achievement/chain unlock streams update
/// on their own whenever those features' controllers write a new unlock
/// or advance a chain. Watching all three here means this provider
/// recomputes whenever any of them do, with no explicit invalidation
/// wiring of its own.

@ProviderFor(identitySnapshot)
final identitySnapshotProvider = IdentitySnapshotProvider._();

/// The Identity page's single source snapshot — reactive to every event
/// that can change it without needing its own evaluation controller (this
/// feature has no write side to trigger from): [totalXpProvider] is
/// already invalidated by `CompleteQuestController` after every quest
/// completion (Phase 6), and the achievement/chain unlock streams update
/// on their own whenever those features' controllers write a new unlock
/// or advance a chain. Watching all three here means this provider
/// recomputes whenever any of them do, with no explicit invalidation
/// wiring of its own.

final class IdentitySnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<IdentitySnapshot>,
          IdentitySnapshot,
          FutureOr<IdentitySnapshot>
        >
    with $FutureModifier<IdentitySnapshot>, $FutureProvider<IdentitySnapshot> {
  /// The Identity page's single source snapshot — reactive to every event
  /// that can change it without needing its own evaluation controller (this
  /// feature has no write side to trigger from): [totalXpProvider] is
  /// already invalidated by `CompleteQuestController` after every quest
  /// completion (Phase 6), and the achievement/chain unlock streams update
  /// on their own whenever those features' controllers write a new unlock
  /// or advance a chain. Watching all three here means this provider
  /// recomputes whenever any of them do, with no explicit invalidation
  /// wiring of its own.
  IdentitySnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identitySnapshotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identitySnapshotHash();

  @$internal
  @override
  $FutureProviderElement<IdentitySnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IdentitySnapshot> create(Ref ref) {
    return identitySnapshot(ref);
  }
}

String _$identitySnapshotHash() => r'd5b5b448fbc08ad77db1c3b69a9bd1abeb805380';

/// Recent milestones, newest first — same reactivity as [identitySnapshotProvider].

@ProviderFor(recentMilestones)
final recentMilestonesProvider = RecentMilestonesProvider._();

/// Recent milestones, newest first — same reactivity as [identitySnapshotProvider].

final class RecentMilestonesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IdentityMilestone>>,
          List<IdentityMilestone>,
          FutureOr<List<IdentityMilestone>>
        >
    with
        $FutureModifier<List<IdentityMilestone>>,
        $FutureProvider<List<IdentityMilestone>> {
  /// Recent milestones, newest first — same reactivity as [identitySnapshotProvider].
  RecentMilestonesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentMilestonesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentMilestonesHash();

  @$internal
  @override
  $FutureProviderElement<List<IdentityMilestone>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<IdentityMilestone>> create(Ref ref) {
    return recentMilestones(ref);
  }
}

String _$recentMilestonesHash() => r'27299c670b3c2b4b19f92a61df7504401229cb0f';

/// A thin projection of [identitySnapshotProvider] — see
/// [AttributeDistribution]'s own doc for why this never recomputes
/// strongest/weakest independently.

@ProviderFor(attributeDistribution)
final attributeDistributionProvider = AttributeDistributionProvider._();

/// A thin projection of [identitySnapshotProvider] — see
/// [AttributeDistribution]'s own doc for why this never recomputes
/// strongest/weakest independently.

final class AttributeDistributionProvider
    extends
        $FunctionalProvider<
          AsyncValue<AttributeDistribution>,
          AttributeDistribution,
          FutureOr<AttributeDistribution>
        >
    with
        $FutureModifier<AttributeDistribution>,
        $FutureProvider<AttributeDistribution> {
  /// A thin projection of [identitySnapshotProvider] — see
  /// [AttributeDistribution]'s own doc for why this never recomputes
  /// strongest/weakest independently.
  AttributeDistributionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attributeDistributionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attributeDistributionHash();

  @$internal
  @override
  $FutureProviderElement<AttributeDistribution> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AttributeDistribution> create(Ref ref) {
    return attributeDistribution(ref);
  }
}

String _$attributeDistributionHash() =>
    r'1ad4f397197c2c03eeee274dba6a7f94a0c85975';

/// A thin projection of [identitySnapshotProvider]'s lifetime counters.

@ProviderFor(lifetimeStatistics)
final lifetimeStatisticsProvider = LifetimeStatisticsProvider._();

/// A thin projection of [identitySnapshotProvider]'s lifetime counters.

final class LifetimeStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<LifetimeStatistics>,
          LifetimeStatistics,
          FutureOr<LifetimeStatistics>
        >
    with
        $FutureModifier<LifetimeStatistics>,
        $FutureProvider<LifetimeStatistics> {
  /// A thin projection of [identitySnapshotProvider]'s lifetime counters.
  LifetimeStatisticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lifetimeStatisticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lifetimeStatisticsHash();

  @$internal
  @override
  $FutureProviderElement<LifetimeStatistics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LifetimeStatistics> create(Ref ref) {
    return lifetimeStatistics(ref);
  }
}

String _$lifetimeStatisticsHash() =>
    r'9de2a5870c37b9df8db34c7789ad6b8c2effee41';
