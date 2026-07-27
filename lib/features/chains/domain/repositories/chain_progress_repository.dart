import '../entities/chain_progress.dart';

abstract class ChainProgressRepository {
  Future<ChainProgress?> getForChain(String chainId);

  Future<List<ChainProgress>> getAll();

  /// Emits the current progress list immediately, then again on every
  /// subsequent change — mirrors `QuestRepository.watchAll()`/
  /// `AchievementUnlockRepository.watchAll()`.
  Stream<List<ChainProgress>> watchAll();

  /// Replaces (or creates) the progress row for [progress.chainId] — unlike
  /// the append-only `AchievementUnlockRepository.appendAll`, chain progress
  /// genuinely mutates over time (stage by stage), so this is a real
  /// upsert, not an idempotent-skip-if-present write. Safety against
  /// duplicate advancement/reward comes from `ChainProgress.completedAt`
  /// being checked before any write is ever attempted, not from this
  /// repository refusing overwrites.
  Future<void> upsert(ChainProgress progress);
}
