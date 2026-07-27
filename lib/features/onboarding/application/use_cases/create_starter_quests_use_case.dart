import '../../../../core/domain/result.dart';
import '../../../quests/application/models/create_quest_command.dart';
import '../../../quests/application/use_cases/create_quest_use_case.dart';
import '../../../quests/domain/entities/quest.dart';
import '../../../quests/domain/repositories/quest_repository.dart';
import '../../domain/catalog/starter_quest_template.dart';

/// Turns a user-selected subset of [starterQuestTemplateCatalog] into real,
/// user-owned quests — through the exact same [CreateQuestUseCase] the
/// create-quest form uses, so a starter quest is completely indistinguishable
/// from one the user typed in by hand. Never awards XP, unlocks, history, or
/// chain progress of its own (Phase 14: "do not create fake XP, unlocks,
/// history, or chain progress") — it only creates the [Quest] rows
/// themselves; everything else is earned normally, later, by completing them.
///
/// Idempotent by title: a template whose title already matches an existing
/// quest is skipped rather than creating a duplicate — covers both a
/// double-tap on the same screen and re-selecting the same template after
/// restarting onboarding from Settings (Phase 14: "starter templates do not
/// duplicate on repeated taps").
class CreateStarterQuestsUseCase {
  const CreateStarterQuestsUseCase({
    required QuestRepository questRepository,
    required CreateQuestUseCase createQuestUseCase,
  }) : _questRepository = questRepository,
       _createQuestUseCase = createQuestUseCase;

  final QuestRepository _questRepository;
  final CreateQuestUseCase _createQuestUseCase;

  Future<Result<List<Quest>>> execute(
    List<StarterQuestTemplate> selected,
  ) async {
    if (selected.isEmpty) return const Ok([]);

    final existingTitles = (await _questRepository.getAll())
        .map((q) => q.title)
        .toSet();
    final created = <Quest>[];

    for (final template in selected) {
      if (existingTitles.contains(template.title)) continue;

      final result = await _createQuestUseCase.execute(
        CreateQuestCommand(
          title: template.title,
          description: template.description,
          type: template.type,
          difficulty: template.difficulty,
          attributeXpWeights: template.attributeXpWeights,
          progressType: template.progressType,
          targetProgress: template.targetProgress,
          repeatability: template.repeatability,
        ),
      );
      switch (result) {
        case Ok(value: final quest):
          created.add(quest);
          existingTitles.add(quest.title);
        case Err(failure: final failure):
          return Err(failure);
      }
    }

    return Ok(created);
  }
}
