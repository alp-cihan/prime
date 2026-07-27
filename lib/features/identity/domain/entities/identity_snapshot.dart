import '../../../../core/domain/attribute_type.dart';

/// A fully-derived read model of "who the player has become" — assembled
/// fresh by `IdentityService` (application layer) from the XP ledger,
/// achievement unlocks, and chain progress every time it's requested, never
/// itself persisted (CLAUDE.md: "Cached XP totals are projections, not the
/// source of truth" — the same rule applies to every number here).
///
/// [currentLevel]/[lifetimeXp]/[xpIntoCurrentLevel]/[xpNeededForNextLevel]
/// mirror `PlayerLevelSummary`'s fields exactly (the "You" tab's XP
/// summary) — deliberately *not* reused as a type here, since that model
/// lives in the xp_ledger feature's presentation layer and this is a
/// domain entity; both are independently derived from the same pure
/// `LevelCurve`, so they can never drift against each other.
class IdentitySnapshot {
  final int currentLevel;
  final int lifetimeXp;
  final int xpIntoCurrentLevel;
  final int xpNeededForNextLevel;

  /// Lifetime XP earned per attribute — the raw distribution every other
  /// attribute-related number here ([strongestAttribute], [weakestAttribute],
  /// [attributePercent]) is computed from, never stored redundantly.
  final Map<AttributeType, int> attributeXp;

  final int completedQuests;
  final int completedChains;
  final int unlockedAchievements;

  /// Consecutive calendar days (ending today or yesterday) with at least
  /// one quest completion — `0` if the player has no activity today or
  /// yesterday (a "broken" streak), not merely absent data. See
  /// `IdentityService`'s doc for exactly how this is derived and why it is
  /// explicitly *not* the forgiveness-token streak system from
  /// docs/architecture.md §11 (not implemented anywhere in this app yet).
  final int currentStreakDays;

  /// UTC date-only. `null` if no quest has ever been completed.
  final DateTime? firstQuestDate;

  /// UTC date-only — the most recent day with any XP-earning activity
  /// (quest completion, achievement, or chain reward). `null` with no
  /// ledger history at all.
  final DateTime? latestActivityDate;

  const IdentitySnapshot({
    required this.currentLevel,
    required this.lifetimeXp,
    required this.xpIntoCurrentLevel,
    required this.xpNeededForNextLevel,
    required this.attributeXp,
    required this.completedQuests,
    required this.completedChains,
    required this.unlockedAchievements,
    required this.currentStreakDays,
    this.firstQuestDate,
    this.latestActivityDate,
  });

  /// `0.0`-`1.0` progress toward [currentLevel]'s next level.
  double get progressRatio {
    if (xpNeededForNextLevel <= 0) return 0.0;
    return (xpIntoCurrentLevel / xpNeededForNextLevel).clamp(0.0, 1.0);
  }

  /// The single highest-XP attribute, or `null` if no attribute has earned
  /// any XP at all (an empty profile has no meaningful "strongest").
  AttributeType? get strongestAttribute => _extreme(pickHighest: true);

  /// The single lowest-XP attribute (deterministically the first, in enum
  /// declaration order, among ties — e.g. several untouched attributes at
  /// `0`), or `null` for an empty profile.
  AttributeType? get weakestAttribute => _extreme(pickHighest: false);

  /// This attribute's share (`0.0`-`1.0`) of total lifetime attribute XP —
  /// `0.0` if no attribute has earned any XP yet.
  double attributePercent(AttributeType type) {
    final total = attributeXp.values.fold<int>(0, (sum, xp) => sum + xp);
    if (total <= 0) return 0.0;
    return (attributeXp[type] ?? 0) / total;
  }

  AttributeType? _extreme({required bool pickHighest}) {
    final hasAnyXp = attributeXp.values.any((xp) => xp > 0);
    if (!hasAnyXp) return null;

    AttributeType? best;
    int? bestXp;
    for (final type in AttributeType.values) {
      final xp = attributeXp[type] ?? 0;
      if (bestXp == null || (pickHighest ? xp > bestXp : xp < bestXp)) {
        bestXp = xp;
        best = type;
      }
    }
    return best;
  }

  @override
  bool operator ==(Object other) {
    if (other is! IdentitySnapshot) return false;
    if (other.currentLevel != currentLevel ||
        other.lifetimeXp != lifetimeXp ||
        other.xpIntoCurrentLevel != xpIntoCurrentLevel ||
        other.xpNeededForNextLevel != xpNeededForNextLevel ||
        other.completedQuests != completedQuests ||
        other.completedChains != completedChains ||
        other.unlockedAchievements != unlockedAchievements ||
        other.currentStreakDays != currentStreakDays ||
        other.firstQuestDate != firstQuestDate ||
        other.latestActivityDate != latestActivityDate ||
        other.attributeXp.length != attributeXp.length) {
      return false;
    }
    for (final entry in attributeXp.entries) {
      if (other.attributeXp[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    currentLevel,
    lifetimeXp,
    xpIntoCurrentLevel,
    xpNeededForNextLevel,
    completedQuests,
    completedChains,
    unlockedAchievements,
    currentStreakDays,
    firstQuestDate,
    latestActivityDate,
    Object.hashAllUnordered(
      attributeXp.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}
