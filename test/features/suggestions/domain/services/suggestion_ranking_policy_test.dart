import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/suggestions/domain/entities/quest_suggestion.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';
import 'package:prime/features/suggestions/domain/services/suggestion_ranking_policy.dart';

QuestSuggestion _suggestion({
  required String id,
  Set<LifeStage> lifeStages = const {},
  Set<GoalArea> goals = const {},
  Map<AttributeType, int> attributeXpWeights = const {AttributeType.health: 20},
  QuestDifficulty difficulty = QuestDifficulty.normal,
  int estimatedMinutes = 10,
  int sortPriority = 10,
}) {
  return QuestSuggestion(
    id: id,
    title: 'Title $id',
    description: 'desc',
    lifeStages: lifeStages,
    goals: goals,
    attributeXpWeights: attributeXpWeights,
    type: QuestType.daily,
    difficulty: difficulty,
    progressType: ProgressType.binary,
    targetProgress: 1,
    repeatability: Repeatability.daily,
    estimatedMinutes: estimatedMinutes,
    visualKey: 'category/$id',
    sortPriority: sortPriority,
  );
}

const _defaultProfile = RecommendationProfile.defaultProfile;

void main() {
  const policy = SuggestionRankingPolicy();

  group('life stage matching', () {
    test('a suggestion matching the profile life stage outranks a universal '
        'one that is otherwise identical', () {
      final matching = _suggestion(
        id: 'matches',
        lifeStages: {LifeStage.student},
      );
      final universal = _suggestion(id: 'universal');

      final ranked = policy.rank(
        catalog: [universal, matching],
        profile: _defaultProfile.copyWith(lifeStage: LifeStage.student),
        existingNormalizedTitles: const {},
      );

      expect(ranked.first.id, 'matches');
    });

    test('explain reports matchesLifeStage only for an exact match', () {
      final suggestion = _suggestion(id: 's', lifeStages: {LifeStage.retired});
      final explanation = policy.explain(
        suggestion,
        _defaultProfile.copyWith(lifeStage: LifeStage.retired),
      );
      expect(explanation.matchesLifeStage, isTrue);

      final mismatch = policy.explain(
        suggestion,
        _defaultProfile.copyWith(lifeStage: LifeStage.student),
      );
      expect(mismatch.matchesLifeStage, isFalse);
    });
  });

  group('goal matching', () {
    test('more overlapping goals ranks higher', () {
      final twoGoals = _suggestion(
        id: 'two',
        goals: {GoalArea.fitness, GoalArea.mindfulness},
      );
      final oneGoal = _suggestion(id: 'one', goals: {GoalArea.fitness});
      final noGoal = _suggestion(id: 'none');

      final ranked = policy.rank(
        catalog: [noGoal, oneGoal, twoGoals],
        profile: _defaultProfile.copyWith(
          goals: {GoalArea.fitness, GoalArea.mindfulness},
        ),
        existingNormalizedTitles: const {},
      );

      expect(ranked.map((s) => s.id).toList(), ['two', 'one', 'none']);
    });

    test('explain reports exactly the intersecting goals', () {
      final suggestion = _suggestion(
        id: 's',
        goals: {GoalArea.finance, GoalArea.organization},
      );
      final explanation = policy.explain(
        suggestion,
        _defaultProfile.copyWith(goals: {GoalArea.finance, GoalArea.reading}),
      );
      expect(explanation.matchingGoals, {GoalArea.finance});
    });
  });

  group('time matching', () {
    test('a suggestion that fits available time outranks one that clearly '
        "doesn't, all else equal", () {
      final fits = _suggestion(id: 'fits', estimatedMinutes: 10);
      final tooLong = _suggestion(id: 'too-long', estimatedMinutes: 90);

      final ranked = policy.rank(
        catalog: [tooLong, fits],
        profile: _defaultProfile.copyWith(availableTime: AvailableTime.under15),
        existingNormalizedTitles: const {},
      );

      expect(ranked.first.id, 'fits');
    });

    test('over60 available time fits any estimated duration', () {
      final suggestion = _suggestion(id: 's', estimatedMinutes: 500);
      final explanation = policy.explain(
        suggestion,
        _defaultProfile.copyWith(availableTime: AvailableTime.over60),
      );
      expect(explanation.fitsAvailableTime, isTrue);
    });
  });

  group('intensity matching', () {
    test('a suggestion matching preferred intensity outranks a mismatched '
        'one, all else equal', () {
      final gentle = _suggestion(
        id: 'gentle',
        difficulty: QuestDifficulty.easy,
      );
      final challenging = _suggestion(
        id: 'challenging',
        difficulty: QuestDifficulty.veryHard,
      );

      final ranked = policy.rank(
        catalog: [challenging, gentle],
        profile: _defaultProfile.copyWith(intensity: PreferredIntensity.gentle),
        existingNormalizedTitles: const {},
      );

      expect(ranked.first.id, 'gentle');
    });

    test('explain matches trivial/easy to gentle, normal to balanced, and '
        'hard/veryHard to challenging', () {
      expect(
        policy
            .explain(
              _suggestion(id: 's', difficulty: QuestDifficulty.trivial),
              _defaultProfile.copyWith(intensity: PreferredIntensity.gentle),
            )
            .matchesIntensity,
        isTrue,
      );
      expect(
        policy
            .explain(
              _suggestion(id: 's', difficulty: QuestDifficulty.normal),
              _defaultProfile.copyWith(intensity: PreferredIntensity.balanced),
            )
            .matchesIntensity,
        isTrue,
      );
      expect(
        policy
            .explain(
              _suggestion(id: 's', difficulty: QuestDifficulty.hard),
              _defaultProfile.copyWith(
                intensity: PreferredIntensity.challenging,
              ),
            )
            .matchesIntensity,
        isTrue,
      );
    });
  });

  group('duplicate filtering', () {
    test('a suggestion whose normalized title matches an existing quest is '
        'excluded', () {
      final suggestion = _suggestion(id: 's1');
      final ranked = policy.rank(
        catalog: [suggestion],
        profile: _defaultProfile,
        existingNormalizedTitles: {
          'title s1',
        }, // normalizeQuestTitle('Title s1')
      );
      expect(ranked, isEmpty);
    });

    test('an already-accepted suggestion id is excluded even if the title '
        "no longer matches (e.g. it was renamed)", () {
      final suggestion = _suggestion(id: 's1');
      final ranked = policy.rank(
        catalog: [suggestion],
        profile: _defaultProfile.copyWith(acceptedSuggestionIds: {'s1'}),
        existingNormalizedTitles: const {},
      );
      expect(ranked, isEmpty);
    });

    test('filterGoals excludes suggestions with no overlapping goal', () {
      final fitness = _suggestion(id: 'fitness', goals: {GoalArea.fitness});
      final finance = _suggestion(id: 'finance', goals: {GoalArea.finance});

      final ranked = policy.rank(
        catalog: [fitness, finance],
        profile: _defaultProfile,
        existingNormalizedTitles: const {},
        filterGoals: {GoalArea.fitness},
      );

      expect(ranked.map((s) => s.id), ['fitness']);
    });
  });

  group('determinism', () {
    test('ranking the same input twice produces the same order', () {
      final catalog = [
        _suggestion(id: 'a', goals: {GoalArea.study}),
        _suggestion(id: 'b', goals: {GoalArea.fitness}),
        _suggestion(id: 'c', goals: {GoalArea.finance}),
        _suggestion(id: 'd', goals: {GoalArea.reading}),
      ];
      final profile = _defaultProfile.copyWith(
        goals: {GoalArea.study, GoalArea.fitness},
      );

      final first = policy
          .rank(
            catalog: catalog,
            profile: profile,
            existingNormalizedTitles: const {},
          )
          .map((s) => s.id)
          .toList();
      final second = policy
          .rank(
            catalog: catalog,
            profile: profile,
            existingNormalizedTitles: const {},
          )
          .map((s) => s.id)
          .toList();

      expect(first, second);
    });

    test('two suggestions tied on every score factor break ties by id', () {
      final b = _suggestion(id: 'b', sortPriority: 10);
      final a = _suggestion(id: 'a', sortPriority: 10);

      final ranked = policy.rank(
        catalog: [b, a],
        profile: _defaultProfile,
        existingNormalizedTitles: const {},
      );

      expect(ranked.map((s) => s.id).toList(), ['a', 'b']);
    });
  });

  group('category diversity', () {
    test('interleaves attributes rather than grouping every suggestion of '
        'one attribute first', () {
      final catalog = [
        _suggestion(
          id: 'health-1',
          attributeXpWeights: {AttributeType.health: 30},
          sortPriority: 10,
        ),
        _suggestion(
          id: 'health-2',
          attributeXpWeights: {AttributeType.health: 25},
          sortPriority: 20,
        ),
        _suggestion(
          id: 'health-3',
          attributeXpWeights: {AttributeType.health: 20},
          sortPriority: 30,
        ),
        _suggestion(
          id: 'knowledge-1',
          attributeXpWeights: {AttributeType.knowledge: 15},
          sortPriority: 40,
        ),
      ];

      final ranked = policy.rank(
        catalog: catalog,
        profile: _defaultProfile,
        existingNormalizedTitles: const {},
      );

      // The knowledge suggestion (lower raw score, smaller bucket) still
      // appears before the third health suggestion — no 3-in-a-row same
      // attribute run when another attribute has anything left to offer.
      final ids = ranked.map((s) => s.id).toList();
      expect(ids.indexOf('knowledge-1'), lessThan(ids.indexOf('health-3')));
    });

    test('every suggestion still appears exactly once', () {
      final catalog = [
        for (var i = 0; i < 5; i++)
          _suggestion(
            id: 'h$i',
            attributeXpWeights: {AttributeType.health: 10 + i},
          ),
        for (var i = 0; i < 5; i++)
          _suggestion(
            id: 'k$i',
            attributeXpWeights: {AttributeType.knowledge: 10 + i},
          ),
      ];

      final ranked = policy.rank(
        catalog: catalog,
        profile: _defaultProfile,
        existingNormalizedTitles: const {},
      );

      expect(ranked.length, catalog.length);
      expect(ranked.map((s) => s.id).toSet(), catalog.map((s) => s.id).toSet());
    });
  });
}
