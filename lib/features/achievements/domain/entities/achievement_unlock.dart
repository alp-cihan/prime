/// An immutable record that one specific [Achievement] was unlocked.
/// Append-only: once written for a given [achievementId], it is never
/// rewritten or removed (mirrors `XpTransaction`'s ledger semantics —
/// CLAUDE.md's "XP transactions are immutable and append-only" applies here
/// too, just for unlock events instead of XP amounts).
///
/// There is no separate `id` field — [achievementId] is already unique per
/// unlock (an achievement unlocks at most once, ever), so it doubles as this
/// record's own identity and its idempotency key.
class AchievementUnlock {
  final String achievementId;
  final DateTime unlockedAt;

  /// The `XpTransaction.idempotencyKey` used for this unlock's reward, if
  /// [Achievement.rewardXp] was greater than zero — `null` if the
  /// achievement carries no reward. Kept here (not re-derived) so a caller
  /// auditing "why did I get this XP" can trace straight from the unlock
  /// record to its ledger row without recomputing the key format.
  final String? rewardIdempotencyKey;

  const AchievementUnlock({
    required this.achievementId,
    required this.unlockedAt,
    this.rewardIdempotencyKey,
  });

  @override
  bool operator ==(Object other) =>
      other is AchievementUnlock &&
      other.achievementId == achievementId &&
      other.unlockedAt == unlockedAt &&
      other.rewardIdempotencyKey == rewardIdempotencyKey;

  @override
  int get hashCode =>
      Object.hash(achievementId, unlockedAt, rewardIdempotencyKey);
}
