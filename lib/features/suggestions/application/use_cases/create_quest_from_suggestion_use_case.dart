import '../../../../core/domain/result.dart';
import '../../../quests/application/models/create_quest_command.dart';
import '../../../quests/application/use_cases/create_quest_use_case.dart';
import '../../../quests/domain/entities/quest.dart';
import '../../../quests/domain/repositories/quest_repository.dart';
import '../../domain/entities/quest_suggestion.dart';
import '../../domain/normalize_title.dart';
import '../../domain/repositories/recommendation_profile_repository.dart';
import '../models/create_quest_from_suggestion_outcome.dart';

/// Turns one [QuestSuggestion] into a real, user-owned [Quest] — through the
/// exact same [CreateQuestUseCase] the create-quest form and onboarding's
/// starter templates use, so an accepted suggestion is indistinguishable
/// from a hand-typed quest, except that it carries the suggestion's
/// [QuestSuggestion.visualKey] forward (Phase 17.2 visual continuity) — the
/// one field a hand-typed quest never has.
///
/// Idempotent by (normalized) title, same strategy as
/// `CreateStarterQuestsUseCase`: a suggestion whose title already matches an
/// existing quest never creates a second one — covers a double-tap that
/// slips past the presentation-layer guard (`SuggestionCreationController`'s
/// `state.isLoading` check) and re-selecting a suggestion that was already
/// accepted in a previous session. It does *not* forbid the user from later
/// creating a similarly-titled quest by hand through the normal form — this
/// check only ever runs when *this* use case is the one creating the quest.
///
/// Always records acceptance via [RecommendationProfileRepository]
/// (`markSuggestionAccepted`), even on the already-exists path — so a
/// suggestion whose title happened to already exist (e.g. the user typed it
/// manually first) is still removed from future ranked lists.
class CreateQuestFromSuggestionUseCase {
  const CreateQuestFromSuggestionUseCase({
    required QuestRepository questRepository,
    required CreateQuestUseCase createQuestUseCase,
    required RecommendationProfileRepository recommendationProfileRepository,
  }) : _questRepository = questRepository,
       _createQuestUseCase = createQuestUseCase,
       _recommendationProfileRepository = recommendationProfileRepository;

  final QuestRepository _questRepository;
  final CreateQuestUseCase _createQuestUseCase;
  final RecommendationProfileRepository _recommendationProfileRepository;

  Future<Result<CreateQuestFromSuggestionOutcome>> execute(
    QuestSuggestion suggestion,
  ) async {
    final normalizedTitle = normalizeQuestTitle(suggestion.title);
    final existingQuests = await _questRepository.getAll();
    for (final quest in existingQuests) {
      if (normalizeQuestTitle(quest.title) == normalizedTitle) {
        await _recommendationProfileRepository.markSuggestionAccepted(
          suggestion.id,
        );
        return Ok(SuggestionAlreadyAdded(quest));
      }
    }

    final result = await _createQuestUseCase.execute(
      CreateQuestCommand(
        title: suggestion.title,
        description: suggestion.description,
        type: suggestion.type,
        difficulty: suggestion.difficulty,
        attributeXpWeights: suggestion.attributeXpWeights,
        progressType: suggestion.progressType,
        targetProgress: suggestion.targetProgress,
        repeatability: suggestion.repeatability,
        visualKey: suggestion.visualKey,
      ),
    );

    switch (result) {
      case Ok(value: final quest):
        await _recommendationProfileRepository.markSuggestionAccepted(
          suggestion.id,
        );
        return Ok(SuggestionQuestCreated(quest));
      case Err(failure: final failure):
        return Err(failure);
    }
  }
}
