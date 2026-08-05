import '../../../../core/domain/attribute_type.dart';
import '../../../quests/domain/entities/quest.dart';
import '../../../quests/domain/entities/repeatability.dart';
import 'recommendation_profile.dart';

/// A code-defined suggestion offered by the Phase 16 recommendation system —
/// not a domain entity of its own, never persisted directly. Selecting one
/// creates a perfectly normal, user-owned [Quest] through the existing
/// quest application layer (`CreateQuestFromSuggestionUseCase` →
/// `CreateQuestUseCase`), so an accepted suggestion is indistinguishable
/// from a hand-typed quest.
class QuestSuggestion {
  final String id;
  final String title;
  final String description;

  /// Optional short "why this helps" line shown on the detail/preview
  /// screen — distinct from the ranking-derived "why it was recommended"
  /// explanation (`SuggestionRankingPolicy.explain`), which is about *this
  /// user's* profile, not the suggestion's own general motivation.
  final String? motivation;

  /// Life stages this suggestion is written for. Empty means "universal" —
  /// applies to anyone regardless of life stage (most fitness/mindfulness/
  /// finance/etc. suggestions), and is scored as a smaller neutral match
  /// rather than a life-stage-specific bonus (see `SuggestionRankingPolicy`).
  final Set<LifeStage> lifeStages;
  final Set<GoalArea> goals;

  /// Compatible 1:1 with `CreateQuestCommand.attributeXpWeights` —
  /// `QuestInputValidator` requires at least one positive entry, which every
  /// catalog entry satisfies (enforced by `quest_suggestion_catalog_test`).
  final Map<AttributeType, int> attributeXpWeights;
  final QuestType type;
  final QuestDifficulty difficulty;
  final ProgressType progressType;
  final double targetProgress;
  final Repeatability repeatability;

  /// Rough real-world time cost, used by ranking's time-fit scoring and
  /// shown directly on suggestion cards — independent of [targetProgress],
  /// since a quantity/binary quest's target isn't a minute count (e.g. "20
  /// push-ups" targets 20 reps but estimates ~5 minutes).
  final int estimatedMinutes;

  /// Structured as `'<category>/<slug>'` (e.g. `'fitness/walk_20'`) purely
  /// as a stable lookup key — `QuestVisual` currently only ever seeds a
  /// deterministic placeholder gradient from it (see `SuggestionCard`). A
  /// future real asset pack can map this same key to a bundled image via a
  /// `Map<String, String>` lookup without touching this entity, the
  /// catalog, or the ranking policy at all.
  final String visualKey;

  /// Catalog-authored prominence, used only as ranking's final tie-breaker
  /// when two suggestions score equally on every profile-driven factor —
  /// never dominant over an actual profile match (see
  /// `SuggestionRankingPolicy`).
  final int sortPriority;

  const QuestSuggestion({
    required this.id,
    required this.title,
    required this.description,
    this.motivation,
    required this.lifeStages,
    required this.goals,
    required this.attributeXpWeights,
    required this.type,
    required this.difficulty,
    required this.progressType,
    required this.targetProgress,
    this.repeatability = Repeatability.daily,
    required this.estimatedMinutes,
    required this.visualKey,
    required this.sortPriority,
  });

  /// The attribute this suggestion contributes the most XP toward — used for
  /// its icon (`attributeIcon`) and for ranking's attribute-diversity pass.
  /// Mirrors `QuestCard`'s identical `_primaryAttribute` helper.
  AttributeType get primaryAttribute {
    var best = attributeXpWeights.entries.first;
    for (final entry in attributeXpWeights.entries.skip(1)) {
      if (entry.value > best.value) best = entry;
    }
    return best.key;
  }
}
