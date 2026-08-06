import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../features/suggestions/domain/entities/recommendation_profile.dart';

/// Presentation-only display strings/icons for the Phase 16 recommendation
/// enums — same rationale as `domain_display_names.dart`: kept out of the
/// domain layer, each taking [BuildContext] to resolve through
/// [AppLocalizations] rather than returning a hardcoded string.
String lifeStageDisplayName(BuildContext context, LifeStage stage) {
  final l10n = AppLocalizations.of(context)!;
  switch (stage) {
    case LifeStage.student:
      return l10n.lifeStageStudent;
    case LifeStage.workingProfessional:
      return l10n.lifeStageWorkingProfessional;
    case LifeStage.entrepreneur:
      return l10n.lifeStageEntrepreneur;
    case LifeStage.homemaker:
      return l10n.lifeStageHomemaker;
    case LifeStage.retired:
      return l10n.lifeStageRetired;
    case LifeStage.other:
      return l10n.lifeStageOther;
  }
}

String goalAreaDisplayName(BuildContext context, GoalArea goal) {
  final l10n = AppLocalizations.of(context)!;
  switch (goal) {
    case GoalArea.study:
      return l10n.goalAreaStudy;
    case GoalArea.career:
      return l10n.goalAreaCareer;
    case GoalArea.fitness:
      return l10n.goalAreaFitness;
    case GoalArea.nutrition:
      return l10n.goalAreaNutrition;
    case GoalArea.sleep:
      return l10n.goalAreaSleep;
    case GoalArea.reading:
      return l10n.goalAreaReading;
    case GoalArea.mindfulness:
      return l10n.goalAreaMindfulness;
    case GoalArea.finance:
      return l10n.goalAreaFinance;
    case GoalArea.relationships:
      return l10n.goalAreaRelationships;
    case GoalArea.organization:
      return l10n.goalAreaOrganization;
    case GoalArea.creativity:
      return l10n.goalAreaCreativity;
    case GoalArea.selfCare:
      return l10n.goalAreaSelfCare;
  }
}

IconData goalAreaIcon(GoalArea goal) {
  switch (goal) {
    case GoalArea.study:
      return Icons.school_outlined;
    case GoalArea.career:
      return Icons.work_outline;
    case GoalArea.fitness:
      return Icons.fitness_center;
    case GoalArea.nutrition:
      return Icons.restaurant_outlined;
    case GoalArea.sleep:
      return Icons.bedtime_outlined;
    case GoalArea.reading:
      return Icons.menu_book_outlined;
    case GoalArea.mindfulness:
      return Icons.self_improvement;
    case GoalArea.finance:
      return Icons.savings_outlined;
    case GoalArea.relationships:
      return Icons.people_outline;
    case GoalArea.organization:
      return Icons.checklist_outlined;
    case GoalArea.creativity:
      return Icons.palette_outlined;
    case GoalArea.selfCare:
      return Icons.spa_outlined;
  }
}

String availableTimeDisplayName(BuildContext context, AvailableTime time) {
  final l10n = AppLocalizations.of(context)!;
  switch (time) {
    case AvailableTime.under15:
      return l10n.availableTimeUnder15;
    case AvailableTime.min15to30:
      return l10n.availableTime15to30;
    case AvailableTime.min30to60:
      return l10n.availableTime30to60;
    case AvailableTime.over60:
      return l10n.availableTimeOver60;
  }
}

String preferredIntensityDisplayName(
  BuildContext context,
  PreferredIntensity intensity,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (intensity) {
    case PreferredIntensity.gentle:
      return l10n.intensityGentle;
    case PreferredIntensity.balanced:
      return l10n.intensityBalanced;
    case PreferredIntensity.challenging:
      return l10n.intensityChallenging;
  }
}
