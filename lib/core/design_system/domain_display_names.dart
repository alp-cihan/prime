import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../domain/attribute_type.dart';
import '../../features/quests/domain/entities/quest.dart';
import '../../features/quests/domain/entities/repeatability.dart';

/// Presentation-only display strings for domain enums. Kept here (not in
/// domain) since domain must stay pure business logic with no UI-facing
/// formatting concerns; each function takes [BuildContext] (rather than
/// returning a hardcoded string) so it can resolve through
/// [AppLocalizations] — the underlying enum names themselves are never
/// translated, only what's shown on screen.
String attributeDisplayName(BuildContext context, AttributeType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case AttributeType.health:
      return l10n.attributeHealth;
    case AttributeType.strength:
      return l10n.attributeStrength;
    case AttributeType.discipline:
      return l10n.attributeDiscipline;
    case AttributeType.knowledge:
      return l10n.attributeKnowledge;
    case AttributeType.career:
      return l10n.attributeCareer;
    case AttributeType.finance:
      return l10n.attributeFinance;
    case AttributeType.relationships:
      return l10n.attributeRelationships;
    case AttributeType.mindfulness:
      return l10n.attributeMindfulness;
  }
}

String questDifficultyDisplayName(
  BuildContext context,
  QuestDifficulty difficulty,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (difficulty) {
    case QuestDifficulty.trivial:
      return l10n.difficultyTrivial;
    case QuestDifficulty.easy:
      return l10n.difficultyEasy;
    case QuestDifficulty.normal:
      return l10n.difficultyNormal;
    case QuestDifficulty.hard:
      return l10n.difficultyHard;
    case QuestDifficulty.veryHard:
      return l10n.difficultyVeryHard;
  }
}

String questTypeDisplayName(BuildContext context, QuestType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case QuestType.daily:
      return l10n.questTypeDaily;
    case QuestType.weekly:
      return l10n.questTypeWeekly;
    case QuestType.monthly:
      return l10n.questTypeMonthly;
    case QuestType.side:
      return l10n.questTypeSide;
    case QuestType.epic:
      return l10n.questTypeEpic;
    case QuestType.mainStory:
      return l10n.questTypeMainStory;
    case QuestType.repeatable:
      return l10n.questTypeRepeatable;
    case QuestType.recovery:
      return l10n.questTypeRecovery;
  }
}

String progressTypeDisplayName(BuildContext context, ProgressType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case ProgressType.binary:
      return l10n.progressTypeBinary;
    case ProgressType.quantity:
      return l10n.progressTypeQuantity;
    case ProgressType.duration:
      return l10n.progressTypeDuration;
  }
}

String repeatabilityDisplayName(
  BuildContext context,
  Repeatability repeatability,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (repeatability) {
    case Repeatability.none:
      return l10n.repeatabilityNone;
    case Repeatability.daily:
      return l10n.repeatabilityDaily;
    case Repeatability.weekly:
      return l10n.repeatabilityWeekly;
  }
}

String questCompletionStateDisplayName(
  BuildContext context,
  QuestCompletionState state,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (state) {
    case QuestCompletionState.notStarted:
      return l10n.questStateNotStarted;
    case QuestCompletionState.inProgress:
      return l10n.questStateInProgress;
    case QuestCompletionState.complete:
      return l10n.questStateComplete;
    case QuestCompletionState.expired:
      return l10n.questStateExpired;
    case QuestCompletionState.converted:
      return l10n.questStateConverted;
  }
}
