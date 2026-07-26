import 'dart:math';

import '../../../../core/domain/attribute_type.dart';
import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../entities/quest.dart';
import 'attribute_xp_allocator.dart';

/// docs/architecture.md §3.2 — only the endpoints (trivial=0.5, veryHard=1.6)
/// are architecture-pinned; the middle tiers are an even progression with
/// `normal` fixed at the neutral 1.0x multiplier. Private and exhaustive:
/// this is the single source for the mapping, and the compiler forces this
/// switch to be updated if a new [QuestDifficulty] is ever added.
extension _QuestDifficultyXp on QuestDifficulty {
  double get xpMultiplier => switch (this) {
    QuestDifficulty.trivial => 0.5,
    QuestDifficulty.easy => 0.75,
    QuestDifficulty.normal => 1.0,
    QuestDifficulty.hard => 1.3,
    QuestDifficulty.veryHard => 1.6,
  };
}

/// The result of a single quest completion's XP calculation: one total plus
/// its exact distribution across attributes (always summing to [totalXp]),
/// and the modifier values that produced it, for later audit/display.
class QuestXpAllocation {
  final int totalXp;
  final Map<AttributeType, int> xpByAttribute;
  final Map<String, double> modifiersApplied;

  const QuestXpAllocation({
    required this.totalXp,
    required this.xpByAttribute,
    required this.modifiersApplied,
  });
}

typedef _Modifiers = ({
  double difficulty,
  double completionRatio,
  double consistency,
  double quality,
  double firstCompletionBonus,
  double diminishingReturns,
});

/// docs/architecture.md §3.1/§3.3 — computes XP for one quest completion as
/// a single quest-level total (not per attribute), then distributes that
/// total across the quest's [Quest.attributeXpWeights] via
/// [AttributeXpAllocator]. XP-ledger concerns (the transaction log itself)
/// live in the xp_ledger feature; this calculator is quest-completion
/// formula behavior and belongs to the quests domain.
class QuestXpCalculator {
  const QuestXpCalculator();

  static const _allocator = AttributeXpAllocator();

  Result<QuestXpAllocation> calculate({
    required Map<AttributeType, int> attributeXpWeights,
    required QuestDifficulty difficulty,
    required double completionRatio,
    required int consecutiveDayStreak,
    int? qualityRating,
    required int repeatIndexToday,
    required int priorXpEarnedTodayForQuest,
    required bool isFirstCompletionEver,
  }) {
    final validationFailure = _validate(
      attributeXpWeights: attributeXpWeights,
      completionRatio: completionRatio,
      consecutiveDayStreak: consecutiveDayStreak,
      qualityRating: qualityRating,
      repeatIndexToday: repeatIndexToday,
      priorXpEarnedTodayForQuest: priorXpEarnedTodayForQuest,
    );
    if (validationFailure != null) {
      return Err(validationFailure);
    }

    final modifiers = _resolveModifiers(
      difficulty: difficulty,
      completionRatio: completionRatio,
      consecutiveDayStreak: consecutiveDayStreak,
      qualityRating: qualityRating,
      isFirstCompletionEver: isFirstCompletionEver,
      repeatIndexToday: repeatIndexToday,
    );

    final totalBaseXp = attributeXpWeights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final rawXp = _calculateRawXp(totalBaseXp, modifiers);
    final totalXp = _applyDailyCap(
      rawXp: rawXp,
      totalBaseXp: totalBaseXp,
      difficultyMultiplier: modifiers.difficulty,
      priorXpEarnedTodayForQuest: priorXpEarnedTodayForQuest,
    );

    return Ok(
      QuestXpAllocation(
        totalXp: totalXp,
        xpByAttribute: _allocator.allocate(totalXp, attributeXpWeights),
        modifiersApplied: {
          'difficulty': modifiers.difficulty,
          'completionRatio': modifiers.completionRatio,
          'consistency': modifiers.consistency,
          'quality': modifiers.quality,
          'firstCompletionBonus': modifiers.firstCompletionBonus,
          'diminishingReturns': modifiers.diminishingReturns,
        },
      ),
    );
  }

  Failure? _validate({
    required Map<AttributeType, int> attributeXpWeights,
    required double completionRatio,
    required int consecutiveDayStreak,
    required int? qualityRating,
    required int repeatIndexToday,
    required int priorXpEarnedTodayForQuest,
  }) {
    if (attributeXpWeights.isEmpty) {
      return const ValidationFailure('attributeXpWeights must not be empty');
    }
    if (attributeXpWeights.values.any((value) => value < 0)) {
      return const ValidationFailure(
        'attributeXpWeights values must not be negative',
      );
    }
    if (completionRatio < 0.0 || completionRatio > 1.0) {
      return const ValidationFailure(
        'completionRatio must be within 0.0 and 1.0',
      );
    }
    if (consecutiveDayStreak < 0) {
      return const ValidationFailure(
        'consecutiveDayStreak must not be negative',
      );
    }
    if (qualityRating != null && (qualityRating < 1 || qualityRating > 5)) {
      return const ValidationFailure('qualityRating must be within 1 and 5');
    }
    if (repeatIndexToday < 0) {
      return const ValidationFailure('repeatIndexToday must not be negative');
    }
    if (priorXpEarnedTodayForQuest < 0) {
      return const ValidationFailure(
        'priorXpEarnedTodayForQuest must not be negative',
      );
    }
    return null;
  }

  _Modifiers _resolveModifiers({
    required QuestDifficulty difficulty,
    required double completionRatio,
    required int consecutiveDayStreak,
    required int? qualityRating,
    required bool isFirstCompletionEver,
    required int repeatIndexToday,
  }) {
    return (
      difficulty: difficulty.xpMultiplier,
      completionRatio: completionRatio,
      consistency: _consistencyMultiplier(consecutiveDayStreak),
      quality: _qualityMultiplier(qualityRating),
      firstCompletionBonus: isFirstCompletionEver ? 1.25 : 1.0,
      diminishingReturns: _diminishingReturnsMultiplier(repeatIndexToday),
    );
  }

  int _calculateRawXp(int totalBaseXp, _Modifiers modifiers) {
    final coreXp =
        (totalBaseXp *
                modifiers.difficulty *
                modifiers.completionRatio *
                modifiers.consistency *
                modifiers.quality)
            .round();
    final withBonus = coreXp * modifiers.firstCompletionBonus;
    final withDiminishingReturns = withBonus * modifiers.diminishingReturns;
    return withDiminishingReturns.round();
  }

  int _applyDailyCap({
    required int rawXp,
    required int totalBaseXp,
    required double difficultyMultiplier,
    required int priorXpEarnedTodayForQuest,
  }) {
    final dailyCap = (totalBaseXp * difficultyMultiplier * 2).round();
    final headroom = max(0, dailyCap - priorXpEarnedTodayForQuest);
    return min(rawXp, headroom);
  }

  double _consistencyMultiplier(int consecutiveDayStreak) {
    final bonus = (0.02 * consecutiveDayStreak).clamp(0.0, 0.3);
    return 1.0 + bonus;
  }

  double _qualityMultiplier(int? qualityRating) {
    if (qualityRating == null) return 1.0;
    return 0.8 + (qualityRating - 1) * 0.1;
  }

  double _diminishingReturnsMultiplier(int repeatIndexToday) {
    if (repeatIndexToday <= 0) return 1.0;
    if (repeatIndexToday == 1) return 0.5;
    return 0.25;
  }
}
