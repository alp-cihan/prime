import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/chains/domain/entities/chain.dart';
import 'package:prime/features/chains/domain/entities/chain_progress.dart';
import 'package:prime/features/chains/domain/entities/chain_stage.dart';
import 'package:prime/features/chains/domain/services/chain_progress_policy.dart';

Chain _chain({
  List<String> questIds = const ['q1', 'q2', 'q3'],
  int rewardXp = 0,
}) {
  return Chain(
    id: 'chain1',
    title: 'Test Chain',
    description: 'desc',
    iconKey: 'book',
    questIds: questIds,
    rewardXp: rewardXp,
    sortOrder: 0,
  );
}

ChainProgress _progress(int completedStageCount, {DateTime? completedAt}) {
  return ChainProgress(
    chainId: 'chain1',
    completedStageCount: completedStageCount,
    completedAt: completedAt,
  );
}

void main() {
  const policy = ChainProgressPolicy();

  test('initial progress starts at zero completed stages', () {
    final progress = policy.initial('chain1');
    expect(progress.completedStageCount, 0);
    expect(progress.completedAt, isNull);
  });

  group('isCompleted', () {
    test('false while fewer stages are completed than exist', () {
      expect(policy.isCompleted(_chain(), _progress(2)), isFalse);
    });

    test('true once every stage is completed', () {
      expect(policy.isCompleted(_chain(), _progress(3)), isTrue);
    });

    test('an empty chain is vacuously always completed', () {
      expect(
        policy.isCompleted(_chain(questIds: const []), _progress(0)),
        isTrue,
      );
    });
  });

  group('hasStarted', () {
    test('false with zero completed stages', () {
      expect(policy.hasStarted(_progress(0)), isFalse);
    });

    test('true once at least one stage is completed', () {
      expect(policy.hasStarted(_progress(1)), isTrue);
    });
  });

  group('unlockedStageCount', () {
    test('the first stage is unlocked from the start', () {
      expect(policy.unlockedStageCount(_chain(), _progress(0)), 1);
    });

    test('grows by one per completed stage', () {
      expect(policy.unlockedStageCount(_chain(), _progress(1)), 2);
    });

    test('clamps at the chain length once complete', () {
      expect(policy.unlockedStageCount(_chain(), _progress(3)), 3);
    });
  });

  group('currentStageIndex', () {
    test('is the next incomplete stage', () {
      expect(policy.currentStageIndex(_chain(), _progress(0)), 0);
      expect(policy.currentStageIndex(_chain(), _progress(1)), 1);
      expect(policy.currentStageIndex(_chain(), _progress(2)), 2);
    });

    test('is null once the chain is fully completed', () {
      expect(policy.currentStageIndex(_chain(), _progress(3)), isNull);
    });
  });

  group('completionPercent', () {
    test('boundaries and midpoints', () {
      expect(policy.completionPercent(_chain(), _progress(0)), 0.0);
      expect(
        policy.completionPercent(_chain(), _progress(1)),
        closeTo(1 / 3, 0.001),
      );
      expect(policy.completionPercent(_chain(), _progress(3)), 1.0);
    });

    test('an empty chain is 100% complete rather than dividing by zero', () {
      expect(
        policy.completionPercent(_chain(questIds: const []), _progress(0)),
        1.0,
      );
    });
  });

  group('stagesFor', () {
    test('marks stages completed/unlocked/locked relative to progress', () {
      final stages = policy.stagesFor(_chain(), _progress(1));

      expect(stages, hasLength(3));
      expect(stages[0].status, ChainStageStatus.completed);
      expect(stages[1].status, ChainStageStatus.unlocked);
      expect(stages[2].status, ChainStageStatus.locked);
      expect(stages[0].questId, 'q1');
      expect(stages[1].questId, 'q2');
      expect(stages[2].questId, 'q3');
      expect(stages.map((s) => s.index).toList(), [0, 1, 2]);
    });

    test('every stage is completed once the chain finishes', () {
      final stages = policy.stagesFor(_chain(), _progress(3));
      expect(
        stages.every((s) => s.status == ChainStageStatus.completed),
        isTrue,
      );
    });
  });

  group('advance', () {
    test('increments completedStageCount by exactly one', () {
      final next = policy.advance(
        _chain(),
        _progress(0),
        instant: DateTime.utc(2026, 1, 10),
      );
      expect(next.completedStageCount, 1);
      expect(next.completedAt, isNull);
    });

    test('sets completedAt only on the transition that finishes the chain', () {
      final next = policy.advance(
        _chain(),
        _progress(2),
        instant: DateTime.utc(2026, 1, 10),
      );
      expect(next.completedStageCount, 3);
      expect(next.completedAt, DateTime.utc(2026, 1, 10));
    });

    test('is a no-op once already completed', () {
      final already = _progress(3, completedAt: DateTime.utc(2026, 1, 1));
      final result = policy.advance(
        _chain(),
        already,
        instant: DateTime.utc(2026, 2, 1),
      );
      expect(result, already);
    });
  });
}
