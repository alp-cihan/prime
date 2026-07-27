import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../achievements/presentation/providers/achievement_query_providers.dart';
import '../../../chains/presentation/providers/chain_query_providers.dart';
import '../../../xp_ledger/presentation/providers/xp_ledger_providers.dart';
import '../../domain/entities/identity_milestone.dart';
import '../../domain/entities/identity_snapshot.dart';
import '../models/attribute_distribution.dart';
import '../models/lifetime_statistics.dart';
import 'identity_repository_providers.dart';

part 'identity_query_providers.g.dart';

/// The Identity page's single source snapshot — reactive to every event
/// that can change it without needing its own evaluation controller (this
/// feature has no write side to trigger from): [totalXpProvider] is
/// already invalidated by `CompleteQuestController` after every quest
/// completion (Phase 6), and the achievement/chain unlock streams update
/// on their own whenever those features' controllers write a new unlock
/// or advance a chain. Watching all three here means this provider
/// recomputes whenever any of them do, with no explicit invalidation
/// wiring of its own.
@riverpod
Future<IdentitySnapshot> identitySnapshot(Ref ref) async {
  ref.watch(totalXpProvider);
  await ref.watch(watchAchievementUnlocksProvider.future);
  await ref.watch(watchAllChainProgressProvider.future);

  final useCase = ref.watch(loadIdentitySnapshotUseCaseProvider);
  final result = await useCase.execute();
  return switch (result) {
    Ok(value: final snapshot) => snapshot,
    Err(failure: final failure) => throw failure,
  };
}

/// Recent milestones, newest first — same reactivity as [identitySnapshotProvider].
@riverpod
Future<List<IdentityMilestone>> recentMilestones(Ref ref) async {
  ref.watch(totalXpProvider);
  await ref.watch(watchAchievementUnlocksProvider.future);
  await ref.watch(watchAllChainProgressProvider.future);

  final useCase = ref.watch(loadRecentMilestonesUseCaseProvider);
  final result = await useCase.execute();
  return switch (result) {
    Ok(value: final milestones) => milestones,
    Err(failure: final failure) => throw failure,
  };
}

/// A thin projection of [identitySnapshotProvider] — see
/// [AttributeDistribution]'s own doc for why this never recomputes
/// strongest/weakest independently.
@riverpod
Future<AttributeDistribution> attributeDistribution(Ref ref) async {
  final snapshot = await ref.watch(identitySnapshotProvider.future);
  return AttributeDistribution.fromSnapshot(snapshot);
}

/// A thin projection of [identitySnapshotProvider]'s lifetime counters.
@riverpod
Future<LifetimeStatistics> lifetimeStatistics(Ref ref) async {
  final snapshot = await ref.watch(identitySnapshotProvider.future);
  return LifetimeStatistics.fromSnapshot(snapshot);
}
