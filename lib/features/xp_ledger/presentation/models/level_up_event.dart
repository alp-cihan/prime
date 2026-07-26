/// docs/architecture.md §14 — a pending level-up celebration. In-memory,
/// session-scoped only: `LevelUpEvent` is derived from XP changes observed
/// during the current app session, never persisted (see
/// `LevelUpController`'s class doc for why re-deriving it from a stored
/// account level on launch must never itself produce one of these).
///
/// [previousLevel]/[newLevel] preserve a multi-level jump (e.g. 2 -> 4) in
/// full — the UI may choose to only display [newLevel], but the event model
/// never collapses the jump into a single generic "leveled up" boolean.
class LevelUpEvent {
  final int previousLevel;
  final int newLevel;
  final int previousTotalXp;
  final int newTotalXp;
  final DateTime occurredAt;

  const LevelUpEvent({
    required this.previousLevel,
    required this.newLevel,
    required this.previousTotalXp,
    required this.newTotalXp,
    required this.occurredAt,
  });

  @override
  bool operator ==(Object other) =>
      other is LevelUpEvent &&
      other.previousLevel == previousLevel &&
      other.newLevel == newLevel &&
      other.previousTotalXp == previousTotalXp &&
      other.newTotalXp == newTotalXp &&
      other.occurredAt == occurredAt;

  @override
  int get hashCode => Object.hash(
    previousLevel,
    newLevel,
    previousTotalXp,
    newTotalXp,
    occurredAt,
  );
}
