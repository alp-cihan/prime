import '../../../../core/domain/attribute_type.dart';
import '../../../../core/domain/failure.dart';
import '../entities/quest.dart';

/// Shared authority for the quest fields Phase 7's create/edit form writes —
/// used by both `CreateQuestUseCase` and `UpdateQuestUseCase` so the two
/// paths can never validate a shared field differently. The UI mirrors a
/// subset of these rules for immediate field-level feedback, but this
/// validator is the final authority: nothing reaches [QuestRepository]
/// without passing it.
class QuestInputValidator {
  const QuestInputValidator();

  static const maxTitleLength = 100;
  static const maxDescriptionLength = 500;

  Failure? validate({
    required String title,
    required String description,
    required Map<AttributeType, int> attributeXpWeights,
    required ProgressType progressType,
    required double targetProgress,
  }) {
    if (title.trim().isEmpty) {
      return const ValidationFailure('Title is required.');
    }
    if (title.trim().length > maxTitleLength) {
      return ValidationFailure(
        'Title must be $maxTitleLength characters or fewer.',
      );
    }
    if (description.trim().length > maxDescriptionLength) {
      return ValidationFailure(
        'Description must be $maxDescriptionLength characters or fewer.',
      );
    }
    if (attributeXpWeights.isEmpty) {
      return const ValidationFailure(
        'At least one attribute allocation is required.',
      );
    }
    if (attributeXpWeights.values.any((value) => value < 0)) {
      return const ValidationFailure(
        'Attribute allocation values must not be negative.',
      );
    }
    if (attributeXpWeights.values.every((value) => value == 0)) {
      return const ValidationFailure(
        'At least one attribute allocation must be greater than zero.',
      );
    }
    if (progressType == ProgressType.binary) {
      if (targetProgress != 1) {
        return const ValidationFailure(
          'Binary quests must have a target progress of 1.',
        );
      }
    } else {
      if (targetProgress <= 0) {
        return const ValidationFailure('Target progress must be positive.');
      }
    }
    return null;
  }
}
