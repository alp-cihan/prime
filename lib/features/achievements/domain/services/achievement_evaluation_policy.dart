import '../entities/achievement.dart';
import '../entities/achievement_trigger.dart';
import 'achievement_criteria_snapshot.dart';

/// The single authority for "does this achievement's criteria hold" and
/// "how close is it" — pure Dart, no repository/ledger access of its own
/// (that composition lives in `AchievementEvaluationService`, application
/// layer). Every decision is a pure function of an already-built
/// [AchievementCriteriaSnapshot], so this is trivially testable with plain
/// data and exhaustive over [AchievementTrigger] — the compiler forces both
/// [isSatisfied] and [_currentValue] to be updated if a new trigger is ever
/// added.
class AchievementEvaluationPolicy {
  const AchievementEvaluationPolicy();

  bool isSatisfied(
    Achievement achievement,
    AchievementCriteriaSnapshot snapshot,
  ) {
    return _currentValue(achievement, snapshot) >= achievement.threshold;
  }

  /// `0.0`-`1.0` progress toward [achievement.threshold] — used by the UI
  /// for a locked achievement's progress affordance. A non-positive
  /// threshold (never produced by the built-in catalog, but not assumed
  /// away here) is treated as "already met" once any progress exists at
  /// all, rather than dividing by zero.
  double progressRatio(
    Achievement achievement,
    AchievementCriteriaSnapshot snapshot,
  ) {
    final current = _currentValue(achievement, snapshot);
    if (achievement.threshold <= 0) return current > 0 ? 1.0 : 0.0;
    return (current / achievement.threshold).clamp(0.0, 1.0);
  }

  int _currentValue(
    Achievement achievement,
    AchievementCriteriaSnapshot snapshot,
  ) {
    switch (achievement.trigger) {
      case AchievementTrigger.totalQuestCompletions:
        return snapshot.totalQuestCompletions;
      case AchievementTrigger.lifetimeXpReached:
        return snapshot.lifetimeXp;
      case AchievementTrigger.playerLevelReached:
        return snapshot.playerLevel;
      case AchievementTrigger.attributeXpReached:
        final attribute = achievement.attributeType;
        if (attribute != null) {
          return snapshot.xpByAttribute[attribute] ?? 0;
        }
        // No specific attribute pinned: "reach the threshold in *any one*
        // attribute" — the highest single attribute total is the relevant
        // reading, not a sum (summing would let eight small totals falsely
        // satisfy a "specialize in one thing" achievement).
        final values = snapshot.xpByAttribute.values;
        return values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
      case AchievementTrigger.hardOrAboveQuestCompleted:
        return snapshot.hardOrAboveCompletionCount;
      case AchievementTrigger.consecutiveDaysCompleted:
        return snapshot.longestConsecutiveCompletionDayStreak;
    }
  }
}
