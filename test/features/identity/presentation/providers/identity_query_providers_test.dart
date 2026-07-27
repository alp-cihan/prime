import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';
import 'package:prime/features/achievements/presentation/providers/achievement_query_providers.dart';
import 'package:prime/features/achievements/presentation/providers/achievement_repository_providers.dart';
import 'package:prime/features/chains/presentation/providers/chain_query_providers.dart';
import 'package:prime/features/identity/domain/entities/identity_milestone.dart';
import 'package:prime/features/identity/presentation/providers/identity_query_providers.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

Future<void> _waitFor(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met within 2 seconds');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

XpTransaction _questTx(String questId, String dateKey, {int finalXp = 100}) {
  final sourceId = '$questId|$dateKey|0';
  return XpTransaction(
    id: '$sourceId|health',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: AttributeType.health,
    baseXp: finalXp,
    modifiersApplied: const {'difficulty': 1.0},
    finalXp: finalXp,
    createdAt: DateTime.utc(2026, 1, 10),
    idempotencyKey: '$sourceId|health',
  );
}

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  /// A persistent listener is required on every autoDispose provider this
  /// suite reads more than once (or reads after an intervening `await`) —
  /// otherwise the scheduler can tear it down between reads before it ever
  /// settles (see `achievement_query_providers_test.dart`'s identical note
  /// about `watchAchievementUnlocksProvider`). [identitySnapshotProvider]
  /// itself transitively depends on the achievement/chain unlock streams,
  /// so those are always kept alive here too.
  void keepAlive(
    ProviderContainer container, {
    bool snapshot = false,
    bool milestones = false,
  }) {
    addTearDown(
      container
          .listen(watchAchievementUnlocksProvider, (previous, next) {})
          .close,
    );
    addTearDown(
      container
          .listen(watchAllChainProgressProvider, (previous, next) {})
          .close,
    );
    if (snapshot) {
      addTearDown(
        container.listen(identitySnapshotProvider, (previous, next) {}).close,
      );
    }
    if (milestones) {
      addTearDown(
        container.listen(recentMilestonesProvider, (previous, next) {}).close,
      );
    }
  }

  test('identitySnapshot resolves to an empty profile with no data', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    keepAlive(container, snapshot: true);

    final snapshot = await container.read(identitySnapshotProvider.future);

    expect(snapshot.currentLevel, 1);
    expect(snapshot.lifetimeXp, 0);
    expect(snapshot.completedQuests, 0);
    expect(snapshot.unlockedAchievements, 0);
  });

  test('recentMilestones is empty with no data', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    keepAlive(container, milestones: true);

    final milestones = await container.read(recentMilestonesProvider.future);
    expect(milestones, isEmpty);
  });

  test(
    'identitySnapshot recomputes once totalXp is invalidated after a ledger write',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      keepAlive(container, snapshot: true);

      final initial = await container.read(identitySnapshotProvider.future);
      expect(initial.lifetimeXp, 0);

      await container.read(xpLedgerRepositoryProvider).appendAll([
        _questTx('q1', '2026-01-10'),
      ]);
      // Mirrors what CompleteQuestController does after a real completion —
      // totalXp has no stream of its own, so it needs an explicit
      // invalidation signal (see xp_ledger_providers.dart's doc).
      container.invalidate(totalXpProvider);

      final updated = await container.read(identitySnapshotProvider.future);
      expect(updated.lifetimeXp, 100);
      expect(updated.completedQuests, 1);
    },
  );

  test(
    'identitySnapshot recomputes automatically when an achievement unlocks',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      keepAlive(container, snapshot: true);

      final initial = await container.read(identitySnapshotProvider.future);
      expect(initial.unlockedAchievements, 0);

      final emissions = <int>[];
      final snapshotSub = container.listen(identitySnapshotProvider, (
        previous,
        next,
      ) {
        if (next.hasValue) emissions.add(next.value!.unlockedAchievements);
      }, fireImmediately: true);
      addTearDown(snapshotSub.close);

      await container.read(achievementUnlockRepositoryProvider).appendAll([
        AchievementUnlock(
          achievementId: 'first_step',
          unlockedAt: DateTime.utc(2026, 1, 10),
        ),
      ]);
      await _waitFor(() => emissions.contains(1));
    },
  );

  test('recentMilestones is newest-first across sources', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    keepAlive(container, milestones: true);

    await container.read(achievementUnlockRepositoryProvider).appendAll([
      AchievementUnlock(
        achievementId: 'first_step',
        unlockedAt: DateTime.utc(2026, 1, 5),
      ),
    ]);
    await container.read(achievementUnlockRepositoryProvider).appendAll([
      AchievementUnlock(
        achievementId: 'getting_started',
        unlockedAt: DateTime.utc(2026, 1, 20),
      ),
    ]);

    final milestones = await container.read(recentMilestonesProvider.future);

    expect(
      milestones
          .where((m) => m.type == IdentityMilestoneType.achievementUnlocked)
          .map((m) => m.title)
          .toList(),
      ['Unlocked "Getting Started"', 'Unlocked "First Step"'],
    );
  });

  test(
    'attributeDistribution and lifetimeStatistics are consistent projections of identitySnapshot',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      keepAlive(container, snapshot: true);

      await container.read(xpLedgerRepositoryProvider).appendAll([
        _questTx('q1', '2026-01-10', finalXp: 150),
      ]);
      container.invalidate(totalXpProvider);

      final snapshot = await container.read(identitySnapshotProvider.future);
      final distribution = await container.read(
        attributeDistributionProvider.future,
      );
      final statistics = await container.read(
        lifetimeStatisticsProvider.future,
      );

      expect(distribution.strongest, snapshot.strongestAttribute);
      expect(distribution.xpByAttribute, snapshot.attributeXp);
      expect(statistics.totalXpEarned, snapshot.lifetimeXp);
      expect(statistics.completedQuests, snapshot.completedQuests);
    },
  );
}
