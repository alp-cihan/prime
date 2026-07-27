import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../domain/entities/quest.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../domain/services/quest_input_validator.dart';
import '../models/update_quest_command.dart';

/// Applies an edit to an existing [Quest]: loads it first (failing with
/// [NotFoundFailure] if it no longer exists), validates the new field
/// values, and persists a new [Quest] that preserves every field the form
/// doesn't expose (`id`, `state`, `currentProgress`,
/// `linkedIdentityStatementIds`, `deadline`, `questChainId`,
/// `prerequisiteQuestIds`, `optionalReward`) unchanged from the existing
/// record.
///
/// Deliberately constructs a new [Quest] directly rather than
/// `existing.copyWith(...)`: [Quest.copyWith] falls back to the existing
/// value via `??` for every parameter, and several fields below (`state`,
/// `currentProgress`, `deadline`, ...) must be preserved unconditionally
/// regardless of what the form submitted — direct construction makes that
/// explicit instead of relying on the form never sending those fields.
///
/// Never touches [QuestProgressRepository] or the XP ledger — editing a
/// quest's definition must never reset progress or rewrite historical
/// ledger rows (CLAUDE.md: "XP transactions are immutable and
/// append-only").
class UpdateQuestUseCase {
  const UpdateQuestUseCase({
    required QuestRepository questRepository,
    QuestInputValidator validator = const QuestInputValidator(),
  }) : _questRepository = questRepository,
       _validator = validator;

  final QuestRepository _questRepository;
  final QuestInputValidator _validator;

  Future<Result<Quest>> execute(UpdateQuestCommand command) async {
    final Quest? existing;
    try {
      existing = await _questRepository.getById(command.questId);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load quest: $e'));
    }
    if (existing == null) {
      return Err(NotFoundFailure('Quest "${command.questId}" was not found'));
    }

    final title = command.title.trim();
    final description = command.description.trim();

    final failure = _validator.validate(
      title: title,
      description: description,
      attributeXpWeights: command.attributeXpWeights,
      progressType: command.progressType,
      targetProgress: command.targetProgress,
    );
    if (failure != null) {
      return Err(failure);
    }

    final updated = Quest(
      id: existing.id,
      title: title,
      description: description,
      type: command.type,
      difficulty: command.difficulty,
      attributeXpWeights: command.attributeXpWeights,
      linkedIdentityStatementIds: existing.linkedIdentityStatementIds,
      progressType: command.progressType,
      currentProgress: existing.currentProgress,
      targetProgress: command.targetProgress,
      deadline: existing.deadline,
      questChainId: existing.questChainId,
      prerequisiteQuestIds: existing.prerequisiteQuestIds,
      state: existing.state,
      failureBehavior: existing.failureBehavior,
      optionalReward: existing.optionalReward,
      repeatability: command.repeatability,
    );

    try {
      await _questRepository.upsert(updated);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to save quest: $e'));
    }

    return Ok(updated);
  }
}
