import '../../../../core/domain/attribute_type.dart';

/// Every fact [AchievementEvaluationPolicy] needs to decide whether an
/// [Achievement]'s criteria are met, computed fresh from the XP ledger (and
/// the level curve) by `AchievementEvaluationService` — never persisted
/// itself, never cached. Deliberately excludes any achievement-reward
/// transactions from the quest-shaped fields ([totalQuestCompletions],
/// [hardOrAboveCompletionCount], [longestConsecutiveCompletionDayStreak]) —
/// see that service's doc for why.
class AchievementCriteriaSnapshot {
  final int totalQuestCompletions;
  final int lifetimeXp;
  final int playerLevel;
  final Map<AttributeType, int> xpByAttribute;
  final int hardOrAboveCompletionCount;
  final int longestConsecutiveCompletionDayStreak;

  const AchievementCriteriaSnapshot({
    required this.totalQuestCompletions,
    required this.lifetimeXp,
    required this.playerLevel,
    required this.xpByAttribute,
    required this.hardOrAboveCompletionCount,
    required this.longestConsecutiveCompletionDayStreak,
  });
}
