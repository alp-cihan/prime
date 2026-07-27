import '../../../../core/domain/attribute_type.dart';
import 'achievement_trigger.dart';

/// A single catalog-defined achievement definition. Instances are
/// compile-time constants (see `achievement_catalog.dart`) — never created
/// by a use case, never persisted themselves (only the fact that one was
/// *unlocked* is persisted, via [AchievementUnlock]). This mirrors
/// docs/architecture.md §8's `Achievement`/`AchievementProgress` split,
/// narrowed to this phase's explicit field list (no `category`/`rarity`/
/// title reward yet — see the Phase 10 completion report for that
/// narrowing).
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconKey;
  final AchievementTrigger trigger;
  final int threshold;

  /// Only meaningful for [AchievementTrigger.attributeXpReached]. `null`
  /// there means "any single attribute reaching [threshold]" rather than one
  /// specific attribute — see that trigger's doc.
  final AttributeType? attributeType;

  /// While `true` and not yet unlocked, the UI must not reveal [title] or
  /// [description] — see `AchievementsPage`.
  final bool hiddenUntilUnlocked;

  /// XP granted, once, on unlock — `0` for a purely cosmetic achievement.
  /// Routed through the XP ledger with a deterministic idempotency key (see
  /// `EvaluateAndUnlockAchievementsUseCase`), never a separate reward
  /// mechanism.
  final int rewardXp;

  /// Display order — independent of catalog declaration order so the
  /// catalog list itself can be reorganized (e.g. grouped by trigger type)
  /// without changing what the user sees first.
  final int sortOrder;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.trigger,
    required this.threshold,
    this.attributeType,
    this.hiddenUntilUnlocked = false,
    this.rewardXp = 0,
    required this.sortOrder,
  });

  @override
  bool operator ==(Object other) =>
      other is Achievement &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.iconKey == iconKey &&
      other.trigger == trigger &&
      other.threshold == threshold &&
      other.attributeType == attributeType &&
      other.hiddenUntilUnlocked == hiddenUntilUnlocked &&
      other.rewardXp == rewardXp &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    iconKey,
    trigger,
    threshold,
    attributeType,
    hiddenUntilUnlocked,
    rewardXp,
    sortOrder,
  );
}
