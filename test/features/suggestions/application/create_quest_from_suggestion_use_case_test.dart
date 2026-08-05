import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/quests/application/id_generator.dart';
import 'package:prime/features/quests/application/models/create_quest_command.dart';
import 'package:prime/features/quests/application/use_cases/create_quest_use_case.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/suggestions/application/models/create_quest_from_suggestion_outcome.dart';
import 'package:prime/features/suggestions/application/use_cases/create_quest_from_suggestion_use_case.dart';
import 'package:prime/features/suggestions/domain/catalog/quest_suggestion_catalog.dart';
import 'package:prime/features/suggestions/domain/entities/quest_suggestion.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';

import '../../../support/fake_repositories.dart';

class _SequentialIdGenerator implements IdGenerator {
  int _next = 0;

  @override
  String generate() => 'id-${_next++}';
}

const _suggestion = QuestSuggestion(
  id: 'test_suggestion',
  title: 'Test Suggestion',
  description: 'desc',
  lifeStages: {},
  goals: {GoalArea.fitness},
  attributeXpWeights: {AttributeType.health: 20},
  type: QuestType.daily,
  difficulty: QuestDifficulty.easy,
  progressType: ProgressType.binary,
  targetProgress: 1,
  repeatability: Repeatability.daily,
  estimatedMinutes: 10,
  visualKey: 'fitness/test',
  sortPriority: 10,
);

void main() {
  late FakeQuestRepository questRepository;
  late FakeRecommendationProfileRepository profileRepository;
  late CreateQuestFromSuggestionUseCase useCase;

  setUp(() {
    questRepository = FakeQuestRepository();
    profileRepository = FakeRecommendationProfileRepository();
    useCase = CreateQuestFromSuggestionUseCase(
      questRepository: questRepository,
      createQuestUseCase: CreateQuestUseCase(
        questRepository: questRepository,
        idGenerator: _SequentialIdGenerator(),
      ),
      recommendationProfileRepository: profileRepository,
    );
  });

  test(
    'creates a normal, user-owned quest through CreateQuestUseCase',
    () async {
      final result = await useCase.execute(_suggestion);

      expect(result, isA<Ok<CreateQuestFromSuggestionOutcome>>());
      final outcome = (result as Ok<CreateQuestFromSuggestionOutcome>).value;
      expect(outcome, isA<SuggestionQuestCreated>());
      expect(outcome.quest.title, _suggestion.title);
      expect(outcome.quest.state, QuestCompletionState.notStarted);
      expect(outcome.quest.currentProgress, 0);
      expect(questRepository.quests.length, 1);
    },
  );

  test('marks the suggestion accepted on the recommendation profile', () async {
    await useCase.execute(_suggestion);

    expect((await profileRepository.get()).acceptedSuggestionIds, {
      'test_suggestion',
    });
  });

  test(
    'a repeated tap creates at most one quest (idempotent by title)',
    () async {
      await useCase.execute(_suggestion);
      expect(questRepository.quests.length, 1);

      final second = await useCase.execute(_suggestion);

      expect(second, isA<Ok<CreateQuestFromSuggestionOutcome>>());
      final outcome = (second as Ok<CreateQuestFromSuggestionOutcome>).value;
      expect(outcome, isA<SuggestionAlreadyAdded>());
      expect(questRepository.quests.length, 1); // still just one
    },
  );

  test('a suggestion whose title already exists (e.g. hand-typed by the '
      'user first) is reported as already-added, not duplicated', () async {
    // Simulates the user typing the exact same title through the normal
    // quest form before ever visiting Suggestions.
    await CreateQuestUseCase(
      questRepository: questRepository,
      idGenerator: _SequentialIdGenerator(),
    ).execute(
      CreateQuestCommand(
        title: _suggestion.title,
        description: 'user-typed description',
        type: QuestType.daily,
        difficulty: QuestDifficulty.normal,
        attributeXpWeights: const {AttributeType.health: 40},
        progressType: ProgressType.binary,
        targetProgress: 1,
      ),
    );

    final result = await useCase.execute(_suggestion);

    final outcome = (result as Ok<CreateQuestFromSuggestionOutcome>).value;
    expect(outcome, isA<SuggestionAlreadyAdded>());
    expect(questRepository.quests.length, 1);
    // Still marked accepted, so it's removed from future ranked lists.
    expect((await profileRepository.get()).acceptedSuggestionIds, {
      'test_suggestion',
    });
  });

  test(
    'every catalog entry is independently creatable through this use case',
    () async {
      for (final suggestion in questSuggestionCatalog.take(10)) {
        final result = await useCase.execute(suggestion);
        expect(
          result,
          isA<Ok<CreateQuestFromSuggestionOutcome>>(),
          reason: suggestion.id,
        );
      }
    },
  );
}
