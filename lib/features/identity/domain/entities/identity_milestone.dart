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

  /// The player level reached — set only when [type] is [levelReached].
  /// Phase 17.3: the presentation layer builds its own localized display
  /// string from this (plus [refId] for the other two types) rather than
  /// showing [title] verbatim, since [title] is always pre-built in English
  /// by `IdentityService` (a pure-Dart application service with no access to
  /// `AppLocalizations`). [title] itself is kept unchanged — still the
  /// English fallback and the field every existing equality check/test
  /// already relies on.
  final int? level;

  /// The stable id this milestone refers to — the unlocked `Achievement.id`
  /// for [IdentityMilestoneType.achievementUnlocked] (looked up through
  /// `achievementTitle()` for a localized name), or the raw `Chain.title`
  /// for [IdentityMilestoneType.chainCompleted] (chain catalog content has
  /// no localized-lookup layer yet — see `chain_catalog.dart`). `null` for
  /// [IdentityMilestoneType.levelReached].
  final String? refId;

  const IdentityMilestone({
    required this.type,
    required this.title,
    required this.iconKey,
    required this.occurredAt,
    this.level,
    this.refId,
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
