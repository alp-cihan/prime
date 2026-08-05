import '../../../quests/domain/entities/quest.dart';

/// Outcome of [CreateQuestFromSuggestionUseCase] — distinguishes "created a
/// new quest" from "you already have this one" so the UI can react
/// differently (a plain success toast vs. "already in your quests") while
/// still, in both cases, being able to open the resulting quest.
sealed class CreateQuestFromSuggestionOutcome {
  const CreateQuestFromSuggestionOutcome();

  Quest get quest;
}

final class SuggestionQuestCreated extends CreateQuestFromSuggestionOutcome {
  const SuggestionQuestCreated(this.quest);

  @override
  final Quest quest;
}

final class SuggestionAlreadyAdded extends CreateQuestFromSuggestionOutcome {
  const SuggestionAlreadyAdded(this.quest);

  @override
  final Quest quest;
}
