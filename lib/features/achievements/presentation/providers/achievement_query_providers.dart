import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/catalog/achievement_catalog.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/achievement_unlock.dart';
import '../models/locked_achievement_progress.dart';
import '../models/unlocked_achievement.dart';
import 'achievement_repository_providers.dart';

part 'achievement_query_providers.g.dart';

/// The built-in catalog, sorted by [Achievement.sortOrder] — every other
/// provider in this file reads the catalog through here, never the raw
/// `achievementCatalog` constant directly, so a test override of this
/// provider consistently affects the whole feature.
@Riverpod(keepAlive: true)
List<Achievement> achievementCatalogList(Ref ref) {
  final sorted = List<Achievement>.of(achievementCatalog)
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return sorted;
}

/// Emits the current unlock history immediately, then again on every
/// subsequent change (`HiveAchievementUnlockRepository.watchAll`'s
/// `Box.watch()`-backed contract) — every widget watching this shares one
/// underlying subscription, same pattern as `watchAllQuestsProvider`.
@riverpod
Stream<List<AchievementUnlock>> watchAchievementUnlocks(Ref ref) {
  final repository = ref.watch(achievementUnlockRepositoryProvider);
  return repository.watchAll();
}

/// Unlocked achievements, sorted most-recently-unlocked first — the
/// Achievements page's "Unlocked" section.
@riverpod
Future<List<UnlockedAchievement>> unlockedAchievements(Ref ref) async {
  final unlocks = await ref.watch(watchAchievementUnlocksProvider.future);
  final catalog = ref.watch(achievementCatalogListProvider);
  final byId = {for (final unlock in unlocks) unlock.achievementId: unlock};

  final result = [
    for (final achievement in catalog)
      if (byId[achievement.id] case final unlock?)
        UnlockedAchievement(
          achievement: achievement,
          unlockedAt: unlock.unlockedAt,
        ),
  ];
  result.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
  return result;
}

/// Locked achievements with their current progress ratio — the Achievements
/// page's "Locked" section. Progress is derived from a fresh criteria
/// snapshot every time this provider recomputes (no separate cached
/// progress value exists anywhere).
@riverpod
Future<List<LockedAchievementProgress>> lockedAchievements(Ref ref) async {
  final unlocks = await ref.watch(watchAchievementUnlocksProvider.future);
  final unlockedIds = unlocks.map((u) => u.achievementId).toSet();
  final catalog = ref.watch(achievementCatalogListProvider);
  final locked = catalog.where((a) => !unlockedIds.contains(a.id)).toList();

  final service = ref.watch(achievementEvaluationServiceProvider);
  final policy = ref.watch(achievementEvaluationPolicyProvider);
  final snapshot = await service.buildSnapshot();

  return [
    for (final achievement in locked)
      LockedAchievementProgress(
        achievement: achievement,
        progressRatio: policy.progressRatio(achievement, snapshot),
      ),
  ];
}

/// Total achievement count — unlocked + locked always sum to this, since
/// every catalog entry is exactly one or the other.
@riverpod
int achievementCatalogCount(Ref ref) =>
    ref.watch(achievementCatalogListProvider).length;
