import '../entities/recommendation_profile.dart';

/// Which parts of a profile a given suggestion matched — pure data, no UI
/// copy (display strings are the presentation layer's job via
/// `suggestion_display_names.dart`). Produced by
/// `SuggestionRankingPolicy.explain`, which also drives scoring, so the
/// reasons shown to the user can never drift from what was actually scored.
class SuggestionMatchExplanation {
  final bool matchesLifeStage;
  final Set<GoalArea> matchingGoals;
  final bool fitsAvailableTime;
  final bool matchesIntensity;

  const SuggestionMatchExplanation({
    required this.matchesLifeStage,
    required this.matchingGoals,
    required this.fitsAvailableTime,
    required this.matchesIntensity,
  });

  /// Whether this suggestion was recommended for a reason specific to the
  /// user, as opposed to being purely universal/generic filler.
  bool get isPersonalizedMatch =>
      matchesLifeStage ||
      matchingGoals.isNotEmpty ||
      fitsAvailableTime ||
      matchesIntensity;
}
