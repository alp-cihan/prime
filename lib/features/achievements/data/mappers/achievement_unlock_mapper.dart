import '../../domain/entities/achievement_unlock.dart';
import '../models/achievement_unlock_hive_model.dart';

/// Explicit domain ↔ persistence mapping for [AchievementUnlock].
class AchievementUnlockMapper {
  const AchievementUnlockMapper();

  AchievementUnlockHiveModel toModel(AchievementUnlock unlock) {
    return AchievementUnlockHiveModel(
      achievementId: unlock.achievementId,
      unlockedAtUtcMicros: unlock.unlockedAt.toUtc().microsecondsSinceEpoch,
      rewardIdempotencyKey: unlock.rewardIdempotencyKey,
    );
  }

  AchievementUnlock toDomain(AchievementUnlockHiveModel model) {
    return AchievementUnlock(
      achievementId: model.achievementId,
      unlockedAt: DateTime.fromMicrosecondsSinceEpoch(
        model.unlockedAtUtcMicros,
        isUtc: true,
      ),
      rewardIdempotencyKey: model.rewardIdempotencyKey,
    );
  }
}
