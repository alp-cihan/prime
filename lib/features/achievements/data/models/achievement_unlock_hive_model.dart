import 'package:hive_ce/hive.dart';

import '../../../../core/persistence/hive_type_ids.dart';

part 'achievement_unlock_hive_model.g.dart';

/// Persisted shape of an [AchievementUnlock]. `unlockedAt` is stored as UTC
/// epoch microseconds (same convention as `QuestProgressHiveModel`/
/// `XpTransactionHiveModel`) so round-tripping never depends on the reading
/// machine's local timezone and never truncates precision.
///
/// Field index map — **never reuse or renumber**:
/// ```text
/// 0 achievementId          2 rewardIdempotencyKey
/// 1 unlockedAtUtcMicros
/// ```
/// Next available index: 3.
@HiveType(typeId: HiveTypeIds.achievementUnlock)
class AchievementUnlockHiveModel {
  @HiveField(0)
  final String achievementId;
  @HiveField(1)
  final int unlockedAtUtcMicros;
  @HiveField(2)
  final String? rewardIdempotencyKey;

  AchievementUnlockHiveModel({
    required this.achievementId,
    required this.unlockedAtUtcMicros,
    this.rewardIdempotencyKey,
  });
}
