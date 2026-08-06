import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

/// ID-keyed lookup from `achievement_catalog.dart`'s stable `Achievement.id`
/// to its localized title/description — deliberately not a second,
/// duplicated catalog: the catalog stays the single source of truth for
/// non-text fields (trigger/threshold/rewardXp/sortOrder/iconKey), and this
/// is the one place that maps an id to display text.
String achievementTitle(BuildContext context, String achievementId) {
  final l10n = AppLocalizations.of(context)!;
  return switch (achievementId) {
    'first_step' => l10n.achievementFirstStepTitle,
    'getting_started' => l10n.achievementGettingStartedTitle,
    'consistent' => l10n.achievementConsistentTitle,
    'experienced' => l10n.achievementExperiencedTitle,
    'xp_hunter' => l10n.achievementXpHunterTitle,
    'specialist' => l10n.achievementSpecialistTitle,
    'challenger' => l10n.achievementChallengerTitle,
    _ => achievementId,
  };
}

String achievementDescription(BuildContext context, String achievementId) {
  final l10n = AppLocalizations.of(context)!;
  return switch (achievementId) {
    'first_step' => l10n.achievementFirstStepDesc,
    'getting_started' => l10n.achievementGettingStartedDesc,
    'consistent' => l10n.achievementConsistentDesc,
    'experienced' => l10n.achievementExperiencedDesc,
    'xp_hunter' => l10n.achievementXpHunterDesc,
    'specialist' => l10n.achievementSpecialistDesc,
    'challenger' => l10n.achievementChallengerDesc,
    _ => '',
  };
}
