import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';
import 'package:prime/features/achievements/presentation/providers/achievement_query_providers.dart';
import 'package:prime/features/achievements/presentation/providers/achievement_repository_providers.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';

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

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  test(
    'achievementCatalogList is sorted by sortOrder and matches the built-in count',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);

      final catalog = container.read(achievementCatalogListProvider);

      expect(catalog, isNotEmpty);
      for (var i = 1; i < catalog.length; i++) {
        expect(catalog[i].sortOrder, greaterThan(catalog[i - 1].sortOrder));
      }
      expect(container.read(achievementCatalogCountProvider), catalog.length);
    },
  );

  test('unlockedAchievements is empty with no unlock history', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    // A persistent listener is required — otherwise the autoDispose
    // `watchAchievementUnlocksProvider` stream this depends on can be torn
    // down by the scheduler before it ever emits.
    final subscription = container.listen(
      watchAchievementUnlocksProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    final result = await container.read(unlockedAchievementsProvider.future);

    expect(result, isEmpty);
  });

  test(
    'unlockedAchievements reflects the unlock repository, most-recent first',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        watchAchievementUnlocksProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      final repo = container.read(achievementUnlockRepositoryProvider);

      await repo.appendAll([
        AchievementUnlock(
          achievementId: 'first_step',
          unlockedAt: DateTime.utc(2026, 1, 1),
        ),
        AchievementUnlock(
          achievementId: 'xp_hunter',
          unlockedAt: DateTime.utc(2026, 2, 1),
        ),
      ]);

      final result = await container.read(unlockedAchievementsProvider.future);

      expect(result.map((u) => u.achievement.id).toList(), [
        'xp_hunter', // most recent
        'first_step',
      ]);
    },
  );

  test(
    'lockedAchievements excludes unlocked entries and reports progress',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        watchAchievementUnlocksProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      final ledger = container.read(xpLedgerRepositoryProvider);
      await ledger.appendAll([
        XpTransaction(
          id: 'q1|2026-01-10|0|health',
          sourceType: XpSourceType.quest,
          sourceId: 'q1|2026-01-10|0',
          attribute: AttributeType.health,
          baseXp: 100,
          modifiersApplied: const {'difficulty': 1.0},
          finalXp: 100,
          createdAt: DateTime.utc(2026, 1, 10),
          idempotencyKey: 'q1|2026-01-10|0|health',
        ),
      ]);

      final locked = await container.read(lockedAchievementsProvider.future);

      final firstStep = locked.firstWhere(
        (e) => e.achievement.id == 'first_step',
      );
      expect(firstStep.progressRatio, 1.0); // 1 completion already satisfies it
      final gettingStarted = locked.firstWhere(
        (e) => e.achievement.id == 'getting_started',
      );
      expect(gettingStarted.progressRatio, closeTo(0.2, 0.001)); // 1/5
    },
  );

  test(
    'watchAchievementUnlocks updates live as unlocks are appended',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      final emissions = <int>[];
      final subscription = container.listen(watchAchievementUnlocksProvider, (
        previous,
        next,
      ) {
        if (next.hasValue) emissions.add(next.value!.length);
      }, fireImmediately: true);
      addTearDown(subscription.close);
      await _waitFor(() => emissions.isNotEmpty);

      await container.read(achievementUnlockRepositoryProvider).appendAll([
        AchievementUnlock(
          achievementId: 'first_step',
          unlockedAt: DateTime.utc(2026, 1, 1),
        ),
      ]);
      await _waitFor(() => emissions.length >= 2);

      expect(emissions.first, 0);
      expect(emissions.last, 1);
    },
  );
}
