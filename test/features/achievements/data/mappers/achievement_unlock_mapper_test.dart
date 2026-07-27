import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/achievements/data/mappers/achievement_unlock_mapper.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';

void main() {
  const mapper = AchievementUnlockMapper();

  test('round-trips every field', () {
    final unlock = AchievementUnlock(
      achievementId: 'first_step',
      unlockedAt: DateTime.utc(2026, 1, 10, 9, 30, 15, 500),
      rewardIdempotencyKey: 'first_step|reward',
    );

    final roundTripped = mapper.toDomain(mapper.toModel(unlock));

    expect(roundTripped, unlock);
  });

  test('round-trips a null rewardIdempotencyKey', () {
    final unlock = AchievementUnlock(
      achievementId: 'cosmetic_only',
      unlockedAt: DateTime.utc(2026, 1, 10),
    );

    final roundTripped = mapper.toDomain(mapper.toModel(unlock));

    expect(roundTripped.rewardIdempotencyKey, isNull);
  });

  test('unlockedAt survives microsecond precision', () {
    final unlock = AchievementUnlock(
      achievementId: 'a',
      unlockedAt: DateTime.utc(2026, 1, 10, 9, 30, 15, 123, 456),
    );

    final roundTripped = mapper.toDomain(mapper.toModel(unlock));

    expect(roundTripped.unlockedAt, unlock.unlockedAt);
  });
}
