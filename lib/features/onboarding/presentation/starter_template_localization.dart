import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

/// ID-keyed lookup from `starter_quest_template.dart`'s stable
/// `StarterQuestTemplate.id` to its localized title/description — same
/// "lookup keyed by stable ID, not a duplicated catalog" approach as
/// `achievement_localization.dart` and `suggestion_localization.dart`.
String starterTemplateTitle(BuildContext context, String templateId) {
  final l10n = AppLocalizations.of(context)!;
  return switch (templateId) {
    'drink_water' => l10n.starterDrinkWaterTitle,
    'read_20_minutes' => l10n.starterRead20Title,
    'walk_15_minutes' => l10n.starterWalk15Title,
    'plan_tomorrow' => l10n.starterPlanTomorrowTitle,
    'complete_a_workout' => l10n.starterWorkoutTitle,
    _ => templateId,
  };
}

String starterTemplateDescription(BuildContext context, String templateId) {
  final l10n = AppLocalizations.of(context)!;
  return switch (templateId) {
    'drink_water' => l10n.starterDrinkWaterDesc,
    'read_20_minutes' => l10n.starterRead20Desc,
    'walk_15_minutes' => l10n.starterWalk15Desc,
    'plan_tomorrow' => l10n.starterPlanTomorrowDesc,
    'complete_a_workout' => l10n.starterWorkoutDesc,
    _ => '',
  };
}
