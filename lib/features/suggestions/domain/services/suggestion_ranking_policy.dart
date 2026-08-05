import '../../../../core/domain/attribute_type.dart';
import '../../../quests/domain/entities/quest.dart';
import '../entities/quest_suggestion.dart';
import '../entities/recommendation_profile.dart';
import '../normalize_title.dart';
import 'suggestion_match_explanation.dart';

/// Pure, deterministic recommendation policy (Phase 16). No randomness, no
/// I/O, no Flutter/Riverpod — a plain scoring + sorting function over
/// in-memory data, so it's trivially unit-testable and reusable from any
/// call site (currently just `GetRankedSuggestionsUseCase`).
///
/// Ranking factors, in the order they're applied:
/// 1. Eligibility filter — already-accepted suggestions, suggestions whose
///    (normalized) title already matches an existing quest, and anything
///    excluded by the caller's goal filter are dropped entirely.
/// 2. Score — life stage, goal overlap, time fit, and intensity fit, each
///    derived from [explain] so the score and the user-facing "why this was
///    recommended" explanation can never disagree; [QuestSuggestion.sortPriority]
///    only breaks ties between otherwise-equal scores.
/// 3. Diversity interleave — suggestions are grouped by
///    [QuestSuggestion.primaryAttribute] and picked round-robin across
///    groups (each group internally still in score order) so the top of the
///    list is never dominated by one attribute/category, and no two
///    consecutive suggestions share a primary attribute unless every other
///    attribute's suggestions have already been exhausted.
class SuggestionRankingPolicy {
  const SuggestionRankingPolicy();

  /// Which parts of [profile] a given [suggestion] matches — also the basis
  /// for [rank]'s scoring, so a suggestion's displayed match reasons always
  /// correspond exactly to why it was ranked where it was.
  SuggestionMatchExplanation explain(
    QuestSuggestion suggestion,
    RecommendationProfile profile,
  ) {
    return SuggestionMatchExplanation(
      matchesLifeStage: suggestion.lifeStages.contains(profile.lifeStage),
      matchingGoals: suggestion.goals.intersection(profile.goals),
      fitsAvailableTime:
          suggestion.estimatedMinutes <= _maxMinutesFor(profile.availableTime),
      matchesIntensity:
          _intensityFor(suggestion.difficulty) == profile.intensity,
    );
  }

  List<QuestSuggestion> rank({
    required List<QuestSuggestion> catalog,
    required RecommendationProfile profile,
    required Set<String> existingNormalizedTitles,
    Set<GoalArea> filterGoals = const <GoalArea>{},
  }) {
    final eligible = catalog.where((suggestion) {
      if (profile.acceptedSuggestionIds.contains(suggestion.id)) return false;
      if (existingNormalizedTitles.contains(
        normalizeQuestTitle(suggestion.title),
      )) {
        return false;
      }
      if (filterGoals.isNotEmpty &&
          suggestion.goals.intersection(filterGoals).isEmpty) {
        return false;
      }
      return true;
    }).toList();

    final scored =
        [
          for (final suggestion in eligible)
            (suggestion: suggestion, score: _score(suggestion, profile)),
        ]..sort((a, b) {
          final cmp = b.score.compareTo(a.score);
          return cmp != 0 ? cmp : a.suggestion.id.compareTo(b.suggestion.id);
        });

    return _interleaveByAttribute(scored);
  }

  /// Groups the already score-sorted list by primary attribute (so each
  /// bucket stays internally in score order) and rounds through the buckets
  /// — buckets ordered by their own best score, ties broken by attribute
  /// name — picking one suggestion per bucket per round until every bucket
  /// is exhausted.
  List<QuestSuggestion> _interleaveByAttribute(
    List<({QuestSuggestion suggestion, double score})> scored,
  ) {
    final buckets = <AttributeType, List<QuestSuggestion>>{};
    final bucketBestScore = <AttributeType, double>{};
    for (final entry in scored) {
      final attribute = entry.suggestion.primaryAttribute;
      buckets.putIfAbsent(attribute, () => []).add(entry.suggestion);
      bucketBestScore.putIfAbsent(attribute, () => entry.score);
    }

    final bucketOrder = buckets.keys.toList()
      ..sort((a, b) {
        final cmp = bucketBestScore[b]!.compareTo(bucketBestScore[a]!);
        return cmp != 0 ? cmp : a.name.compareTo(b.name);
      });

    final result = <QuestSuggestion>[];
    var round = 0;
    var addedThisRound = true;
    while (addedThisRound) {
      addedThisRound = false;
      for (final attribute in bucketOrder) {
        final bucket = buckets[attribute]!;
        if (round < bucket.length) {
          result.add(bucket[round]);
          addedThisRound = true;
        }
      }
      round++;
    }
    return result;
  }

  double _score(QuestSuggestion suggestion, RecommendationProfile profile) {
    final explanation = explain(suggestion, profile);
    var score = 0.0;

    if (explanation.matchesLifeStage) {
      score += 3;
    } else if (suggestion.lifeStages.isEmpty) {
      score += 1; // universal suggestions get a small neutral baseline
    }

    score += explanation.matchingGoals.length * 2.0;

    if (explanation.fitsAvailableTime) {
      score += 2;
    } else if (suggestion.estimatedMinutes >
        _maxMinutesFor(profile.availableTime) * 2) {
      score -= 2; // clearly too long for the time available
    }

    if (explanation.matchesIntensity) {
      score += 2;
    } else if (_intensityDistance(suggestion.difficulty, profile.intensity) ==
        1) {
      score += 1; // adjacent intensity (e.g. gentle vs. balanced)
    }

    // Tie-breaker only — deliberately small relative to every factor above.
    score -= suggestion.sortPriority * 0.001;

    return score;
  }

  int _maxMinutesFor(AvailableTime time) => switch (time) {
    AvailableTime.under15 => 15,
    AvailableTime.min15to30 => 30,
    AvailableTime.min30to60 => 60,
    AvailableTime.over60 => 1 << 30,
  };

  PreferredIntensity _intensityFor(QuestDifficulty difficulty) =>
      switch (difficulty) {
        QuestDifficulty.trivial ||
        QuestDifficulty.easy => PreferredIntensity.gentle,
        QuestDifficulty.normal => PreferredIntensity.balanced,
        QuestDifficulty.hard ||
        QuestDifficulty.veryHard => PreferredIntensity.challenging,
      };

  static const _intensityOrder = [
    PreferredIntensity.gentle,
    PreferredIntensity.balanced,
    PreferredIntensity.challenging,
  ];

  int _intensityDistance(
    QuestDifficulty difficulty,
    PreferredIntensity intensity,
  ) {
    final suggestionIntensity = _intensityFor(difficulty);
    return (_intensityOrder.indexOf(suggestionIntensity) -
            _intensityOrder.indexOf(intensity))
        .abs();
  }
}
