/// Phase 10 MVP — the exhaustive set of achievement criteria this system
/// can evaluate. Deliberately narrow: docs/architecture.md §8 describes a
/// much richer unlock-rule system (arbitrary declarative rules against
/// ledger aggregates), but this phase's explicit scope is these six trigger
/// shapes only. Extending the catalog with a genuinely new criterion means
/// adding a case here — the compiler then forces every `switch` over this
/// enum (`AchievementEvaluationPolicy`) to be updated.
enum AchievementTrigger {
  /// [Achievement.threshold] distinct quest-completion events, lifetime.
  totalQuestCompletions,

  /// [Achievement.threshold] lifetime XP, summed across every attribute.
  lifetimeXpReached,

  /// [Achievement.threshold] as a global player level (docs/architecture.md
  /// §4.1's curve).
  playerLevelReached,

  /// [Achievement.threshold] XP in [Achievement.attributeType] — or, if that
  /// field is left `null`, in *any* single attribute (the highest one).
  attributeXpReached,

  /// [Achievement.threshold] distinct completions of a quest whose
  /// difficulty was Hard or Very Hard.
  hardOrAboveQuestCompleted,

  /// [Achievement.threshold] as a longest-ever run of consecutive calendar
  /// days with at least one quest completion each.
  consecutiveDaysCompleted,
}
