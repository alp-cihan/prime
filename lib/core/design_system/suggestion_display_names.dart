import 'package:flutter/material.dart';

import '../../features/suggestions/domain/entities/recommendation_profile.dart';

/// Presentation-only display strings/icons for the Phase 16 recommendation
/// enums — same rationale as `domain_display_names.dart`: kept out of the
/// domain layer, kept as plain functions so any dumb widget can use them
/// without pulling in Riverpod or BuildContext.
String lifeStageDisplayName(LifeStage stage) {
  switch (stage) {
    case LifeStage.student:
      return 'Student';
    case LifeStage.workingProfessional:
      return 'Working professional';
    case LifeStage.entrepreneur:
      return 'Entrepreneur';
    case LifeStage.homemaker:
      return 'Homemaker';
    case LifeStage.retired:
      return 'Retired';
    case LifeStage.other:
      return 'Other';
  }
}

String goalAreaDisplayName(GoalArea goal) {
  switch (goal) {
    case GoalArea.study:
      return 'Study';
    case GoalArea.career:
      return 'Career';
    case GoalArea.fitness:
      return 'Fitness';
    case GoalArea.nutrition:
      return 'Nutrition';
    case GoalArea.sleep:
      return 'Sleep';
    case GoalArea.reading:
      return 'Reading';
    case GoalArea.mindfulness:
      return 'Mindfulness';
    case GoalArea.finance:
      return 'Finance';
    case GoalArea.relationships:
      return 'Relationships';
    case GoalArea.organization:
      return 'Organization';
    case GoalArea.creativity:
      return 'Creativity';
    case GoalArea.selfCare:
      return 'Self-care';
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

String availableTimeDisplayName(AvailableTime time) {
  switch (time) {
    case AvailableTime.under15:
      return 'Under 15 minutes';
    case AvailableTime.min15to30:
      return '15–30 minutes';
    case AvailableTime.min30to60:
      return '30–60 minutes';
    case AvailableTime.over60:
      return 'Over 60 minutes';
  }
}

String preferredIntensityDisplayName(PreferredIntensity intensity) {
  switch (intensity) {
    case PreferredIntensity.gentle:
      return 'Gentle';
    case PreferredIntensity.balanced:
      return 'Balanced';
    case PreferredIntensity.challenging:
      return 'Challenging';
  }
}
