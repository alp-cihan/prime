/// Phase 16 — practical preference data used to personalize quest
/// suggestions. Deliberately excludes anything not needed for ranking (no
/// gender, no medical/nutrition data) per the phase's non-goals.
enum LifeStage {
  student,
  workingProfessional,
  entrepreneur,
  homemaker,
  retired,
  other,
}

/// Interest/goal areas a suggestion can be tagged with. `creativity` and
/// `selfCare`/`organization`/`sleep` have no dedicated [AttributeType] of
/// their own — the catalog maps them onto the closest existing attribute
/// (see `quest_suggestion_catalog.dart`'s doc comment) rather than growing
/// the 8-attribute system for this phase.
enum GoalArea {
  study,
  career,
  fitness,
  nutrition,
  sleep,
  reading,
  mindfulness,
  finance,
  relationships,
  organization,
  creativity,
  selfCare,
}

enum AvailableTime { under15, min15to30, min30to60, over60 }

enum PreferredIntensity { gentle, balanced, challenging }

/// A user's local, on-device recommendation preferences. Never synced,
/// never sent anywhere — used only to rank `QuestSuggestion`s
/// (`SuggestionRankingPolicy`). [acceptedSuggestionIds] tracks which
/// catalog suggestions have already been turned into a real quest, so the
/// ranked list never re-offers one the user already has.
class RecommendationProfile {
  final LifeStage lifeStage;
  final Set<GoalArea> goals;
  final AvailableTime availableTime;
  final PreferredIntensity intensity;

  /// `false` until the user has explicitly saved the preferences editor at
  /// least once — distinguishes "never asked" from "asked and chose
  /// defaults," so the UI can show a one-time "personalize this" prompt only
  /// in the former case.
  final bool isPersonalized;
  final Set<String> acceptedSuggestionIds;

  const RecommendationProfile({
    required this.lifeStage,
    required this.goals,
    required this.availableTime,
    required this.intensity,
    required this.isPersonalized,
    required this.acceptedSuggestionIds,
  });

  static const RecommendationProfile defaultProfile = RecommendationProfile(
    lifeStage: LifeStage.other,
    goals: <GoalArea>{},
    availableTime: AvailableTime.min30to60,
    intensity: PreferredIntensity.balanced,
    isPersonalized: false,
    acceptedSuggestionIds: <String>{},
  );

  RecommendationProfile copyWith({
    LifeStage? lifeStage,
    Set<GoalArea>? goals,
    AvailableTime? availableTime,
    PreferredIntensity? intensity,
    bool? isPersonalized,
    Set<String>? acceptedSuggestionIds,
  }) {
    return RecommendationProfile(
      lifeStage: lifeStage ?? this.lifeStage,
      goals: goals ?? this.goals,
      availableTime: availableTime ?? this.availableTime,
      intensity: intensity ?? this.intensity,
      isPersonalized: isPersonalized ?? this.isPersonalized,
      acceptedSuggestionIds:
          acceptedSuggestionIds ?? this.acceptedSuggestionIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! RecommendationProfile) return false;
    return other.lifeStage == lifeStage &&
        other.availableTime == availableTime &&
        other.intensity == intensity &&
        other.isPersonalized == isPersonalized &&
        _setEquals(other.goals, goals) &&
        _setEquals(other.acceptedSuggestionIds, acceptedSuggestionIds);
  }

  @override
  int get hashCode => Object.hash(
    lifeStage,
    availableTime,
    intensity,
    isPersonalized,
    Object.hashAllUnordered(goals),
    Object.hashAllUnordered(acceptedSuggestionIds),
  );
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  return a.containsAll(b);
}
