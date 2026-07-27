/// The kind of historical event an [IdentityMilestone] represents.
enum IdentityMilestoneType { levelReached, achievementUnlocked, chainCompleted }

/// One notable historical event, reconstructed by `IdentityService` from
/// existing authoritative data (the XP ledger, achievement unlocks, chain
/// progress) — never its own persisted record. Immutable: once built, a
/// milestone describes a moment that already happened and cannot change
/// (CLAUDE.md-adjacent: identity milestones are a read model, exactly like
/// `XpTransaction` rows are for the ledger — the underlying facts are
/// append-only/immutable, so the same is true of anything derived from
/// them).
class IdentityMilestone {
  final IdentityMilestoneType type;
  final String title;
  final String iconKey;
  final DateTime occurredAt;

  const IdentityMilestone({
    required this.type,
    required this.title,
    required this.iconKey,
    required this.occurredAt,
  });

  @override
  bool operator ==(Object other) =>
      other is IdentityMilestone &&
      other.type == type &&
      other.title == title &&
      other.iconKey == iconKey &&
      other.occurredAt == occurredAt;

  @override
  int get hashCode => Object.hash(type, title, iconKey, occurredAt);
}
