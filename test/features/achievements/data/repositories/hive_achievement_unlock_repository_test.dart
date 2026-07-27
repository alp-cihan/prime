import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/achievements/data/models/achievement_unlock_hive_model.dart';
import 'package:prime/features/achievements/data/repositories/hive_achievement_unlock_repository.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';

import '../../../../support/hive_test_support.dart';

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  Future<Box<AchievementUnlockHiveModel>> openBox() =>
      Hive.openBox<AchievementUnlockHiveModel>(HiveBoxNames.achievementUnlocks);

  test('appendAll then getAll returns what was appended', () async {
    final repo = HiveAchievementUnlockRepository(await openBox());
    final unlock = AchievementUnlock(
      achievementId: 'first_step',
      unlockedAt: DateTime.utc(2026, 1, 10),
      rewardIdempotencyKey: 'first_step|reward',
    );

    await repo.appendAll([unlock]);

    expect(await repo.getAll(), [unlock]);
    expect(await repo.isUnlocked('first_step'), isTrue);
    expect(await repo.isUnlocked('never_unlocked'), isFalse);
  });

  test('appendAll never overwrites an existing unlock (append-only)', () async {
    final repo = HiveAchievementUnlockRepository(await openBox());
    final original = AchievementUnlock(
      achievementId: 'first_step',
      unlockedAt: DateTime.utc(2026, 1, 10),
    );
    await repo.appendAll([original]);

    // A conflicting "retry" with a different timestamp must be ignored.
    await repo.appendAll([
      AchievementUnlock(
        achievementId: 'first_step',
        unlockedAt: DateTime.utc(2027, 6, 1),
      ),
    ]);

    final all = await repo.getAll();
    expect(all.length, 1);
    expect(all.single.unlockedAt, original.unlockedAt);
  });

  test(
    'watchAll emits the current snapshot immediately, then again on change',
    () async {
      final repo = HiveAchievementUnlockRepository(await openBox());
      final emissions = <int>[];
      final subscription = repo.watchAll().listen(
        (u) => emissions.add(u.length),
      );
      await pumpEventQueue();

      await repo.appendAll([
        AchievementUnlock(
          achievementId: 'a',
          unlockedAt: DateTime.utc(2026, 1, 10),
        ),
      ]);
      await pumpEventQueue();

      await subscription.cancel();
      expect(emissions, [0, 1]);
    },
  );

  test('survives closing and reopening the box', () async {
    final unlock = AchievementUnlock(
      achievementId: 'xp_hunter',
      unlockedAt: DateTime.utc(2026, 1, 10),
      rewardIdempotencyKey: 'xp_hunter|reward',
    );
    await HiveAchievementUnlockRepository(await openBox()).appendAll([unlock]);

    await support.reopen();

    final reopened = HiveAchievementUnlockRepository(await openBox());
    expect(await reopened.getAll(), [unlock]);
  });
}
