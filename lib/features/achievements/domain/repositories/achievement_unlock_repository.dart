import '../entities/achievement_unlock.dart';

abstract class AchievementUnlockRepository {
  Future<List<AchievementUnlock>> getAll();

  Future<bool> isUnlocked(String achievementId);

  /// Emits the current set of unlocks immediately, then again on every
  /// subsequent change — the achievements list's stream-backed source of
  /// truth, mirroring `QuestRepository.watchAll()`.
  Stream<List<AchievementUnlock>> watchAll();

  /// Appends new unlock records, skipping any whose [AchievementUnlock.achievementId]
  /// already has one recorded — append-only and idempotent, exactly like
  /// [XpLedgerRepository.appendAll]. A retry of an already-unlocked
  /// achievement is a safe no-op.
  Future<void> appendAll(List<AchievementUnlock> unlocks);
}
