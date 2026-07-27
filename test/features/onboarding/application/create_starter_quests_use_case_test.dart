import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/onboarding/application/use_cases/create_starter_quests_use_case.dart';
import 'package:prime/features/onboarding/domain/catalog/starter_quest_template.dart';
import 'package:prime/features/quests/application/id_generator.dart';
import 'package:prime/features/quests/application/use_cases/create_quest_use_case.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';

import '../../../support/fake_repositories.dart';

class _SequentialIdGenerator implements IdGenerator {
  int _next = 0;

  @override
  String generate() => 'id-${_next++}';
}

void main() {
  late FakeQuestRepository questRepository;
  late CreateStarterQuestsUseCase useCase;

  setUp(() {
    questRepository = FakeQuestRepository();
    useCase = CreateStarterQuestsUseCase(
      questRepository: questRepository,
      createQuestUseCase: CreateQuestUseCase(
        questRepository: questRepository,
        idGenerator: _SequentialIdGenerator(),
      ),
    );
  });

  test('an empty selection creates nothing', () async {
    final result = await useCase.execute(const []);

    expect(result, isA<Ok<List<Quest>>>());
    expect((result as Ok<List<Quest>>).value, isEmpty);
    expect(questRepository.quests, isEmpty);
  });

  test(
    'creates a normal, user-owned quest for each selected template',
    () async {
      final selected = [
        starterQuestTemplateCatalog[0],
        starterQuestTemplateCatalog[2],
      ];

      final result = await useCase.execute(selected);

      expect(result, isA<Ok<List<Quest>>>());
      final created = (result as Ok<List<Quest>>).value;
      expect(created.map((q) => q.title), [
        starterQuestTemplateCatalog[0].title,
        starterQuestTemplateCatalog[2].title,
      ]);
      expect(questRepository.quests.length, 2);
      // Went through the real CreateQuestUseCase — normal fields, not a
      // special "template" flag or state.
      final quest = created.first;
      expect(quest.state, QuestCompletionState.notStarted);
      expect(quest.currentProgress, 0);
    },
  );

  test('a template whose title already exists as a quest is skipped, not '
      'duplicated — covers a double-tap and re-selecting after restarting '
      'onboarding', () async {
    final template = starterQuestTemplateCatalog[0];
    // First selection.
    await useCase.execute([template]);
    expect(questRepository.quests.length, 1);

    // Re-running with the same template (e.g. a double-tap, or restarting
    // onboarding and selecting it again) must not create a second quest.
    final result = await useCase.execute([template]);

    expect(result, isA<Ok<List<Quest>>>());
    expect((result as Ok<List<Quest>>).value, isEmpty); // nothing new
    expect(questRepository.quests.length, 1);
  });

  test(
    'selecting the same template twice within one call creates only one quest',
    () async {
      final template = starterQuestTemplateCatalog[0];

      final result = await useCase.execute([template, template]);

      expect(result, isA<Ok<List<Quest>>>());
      expect((result as Ok<List<Quest>>).value.length, 1);
      expect(questRepository.quests.length, 1);
    },
  );

  test('every catalog template is independently valid and creatable', () async {
    final result = await useCase.execute(starterQuestTemplateCatalog);

    expect(result, isA<Ok<List<Quest>>>());
    expect(
      (result as Ok<List<Quest>>).value.length,
      starterQuestTemplateCatalog.length,
    );
  });
}
