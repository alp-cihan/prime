/// A single Quest Chain definition — a linear sequence of quests that
/// unlock progressively, one at a time (docs/architecture.md §6's
/// narrower Phase 11 MVP: no branching, one chapter unlocked at a time).
/// Instances are compile-time constants (see `chain_catalog.dart`) — never
/// created by a use case, never persisted themselves (only [ChainProgress]
/// is persisted, per this phase's explicit "keep chain definitions
/// code-based" rule).
///
/// [questIds] deliberately holds real `Quest.id` values from the quest
/// repository, in completion order — this phase's built-in catalog is
/// therefore empty by default (a compile-time chain can't reference a quest
/// id that doesn't exist until a user creates one), but the mechanism is
/// fully implemented and extensible for a future release that ships fixed
/// onboarding quests alongside their chain. See the Phase 11 completion
/// report for this reasoning.
class Chain {
  final String id;
  final String title;
  final String description;
  final String iconKey;
  final List<String> questIds;

  /// XP granted, once, when the final stage completes — `0` for a purely
  /// cosmetic chain. Routed through the XP ledger with a deterministic
  /// idempotency key (see `EvaluateAndAdvanceChainsUseCase`), never a
  /// separate reward mechanism.
  final int rewardXp;

  /// While `true` and the chain has no progress yet (nothing started),
  /// the UI must not reveal [title]/[description] — mirrors
  /// `Achievement.hiddenUntilUnlocked`'s masking rule, for a chain the
  /// player hasn't discovered yet.
  final bool hiddenUntilStarted;

  /// Display order — independent of catalog declaration order.
  final int sortOrder;

  const Chain({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.questIds,
    this.rewardXp = 0,
    this.hiddenUntilStarted = false,
    required this.sortOrder,
  });

  @override
  bool operator ==(Object other) {
    if (other is! Chain) return false;
    if (other.id != id ||
        other.title != title ||
        other.description != description ||
        other.iconKey != iconKey ||
        other.rewardXp != rewardXp ||
        other.hiddenUntilStarted != hiddenUntilStarted ||
        other.sortOrder != sortOrder ||
        other.questIds.length != questIds.length) {
      return false;
    }
    for (var i = 0; i < questIds.length; i++) {
      if (other.questIds[i] != questIds[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    iconKey,
    rewardXp,
    hiddenUntilStarted,
    sortOrder,
    Object.hashAll(questIds),
  );
}
