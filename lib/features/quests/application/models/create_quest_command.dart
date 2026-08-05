import '../../../../core/domain/attribute_type.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/repeatability.dart';

/// Input to [CreateQuestUseCase] — exactly the fields Phase 7's form exposes,
/// plus [visualKey] (Phase 17.2). Deliberately absent: `id` (assigned by the
/// injected `IdGenerator`, never the caller), `state`/`currentProgress`
/// (always `notStarted`/`0` for a new quest), and every quest-chain/
/// identity/reward/deadline field — those systems don't exist yet, so
/// [CreateQuestUseCase] fills them with the same inert defaults every
/// existing test fixture already uses.
class CreateQuestCommand {
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final Map<AttributeType, int> attributeXpWeights;
  final ProgressType progressType;
  final double targetProgress;
  final Repeatability repeatability;

  /// `null` for a hand-typed quest (the create-quest form has no visual
  /// picker) — only [CreateQuestFromSuggestionUseCase] currently passes one,
  /// copied straight from the originating `QuestSuggestion.visualKey`.
  final String? visualKey;

  const CreateQuestCommand({
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.attributeXpWeights,
    required this.progressType,
    required this.targetProgress,
    this.repeatability = Repeatability.none,
    this.visualKey,
  });
}
