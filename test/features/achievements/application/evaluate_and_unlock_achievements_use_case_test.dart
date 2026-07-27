import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/clock.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/achievements/application/services/achievement_evaluation_service.dart';
import 'package:prime/features/achievements/application/use_cases/evaluate_and_unlock_achievements_use_case.dart';
import 'package:prime/features/achievements/domain/entities/achievement.dart';
import 'package:prime/features/achievements/domain/entities/achievement_trigger.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';
import 'package:prime/features/achievements/domain/repositories/achievement_unlock_repository.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/domain/repositories/xp_ledger_repository.dart';

class _FakeXpLedgerRepository implements XpLedgerRepository {
  final Map<String, XpTransaction> byKey = {};
  int appendAllCallCount = 0;

  @override
  Future<void> appendAll(List<XpTransaction> transactions) async {
    appendAllCallCount++;
    for (final t in transactions) {
      byKey.putIfAbsent(t.idempotencyKey, () => t);
    }
  }

  @override
  Future<List<XpTransaction>> getTransactionsForQuestAndDate(
    String questId,
    DateTime date,
  ) async => throw UnimplementedError();

  @override
  Future<List<XpTransaction>> getTransactionsForQuest(String questId) async =>
      throw UnimplementedError();

  @override
  Future<List<XpTransaction>> getTransactionsForDate(DateTime date) async =>
      throw UnimplementedError();

  @override
  Future<List<XpTransaction>> getAll() async => byKey.values.toList();

  @override
  Future<int> sumLifetimeXp() async =>
      byKey.values.fold<int>(0, (sum, t) => sum + t.finalXp);

  @override
  Future<int> sumXpForAttribute(AttributeType type) async => byKey.values
      .where((t) => t.attribute == type)
      .fold<int>(0, (sum, t) => sum + t.finalXp);
}

class _FakeAchievementUnlockRepository implements AchievementUnlockRepository {
  final Map<String, AchievementUnlock> unlocks = {};
  int appendAllCallCount = 0;
  Object? appendAllError;

  @override
  Future<List<AchievementUnlock>> getAll() async => unlocks.values.toList();

  @override
  Future<bool> isUnlocked(String achievementId) async =>
      unlocks.containsKey(achievementId);

  @override
  Stream<List<AchievementUnlock>> watchAll() =>
      Stream.value(unlocks.values.toList());

  @override
  Future<void> appendAll(List<AchievementUnlock> newUnlocks) async {
    appendAllCallCount++;
    if (appendAllError != null) throw appendAllError!;
    for (final unlock in newUnlocks) {
      unlocks.putIfAbsent(unlock.achievementId, () => unlock);
    }
  }
}

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

const _oneShotAchievement = Achievement(
  id: 'first_step',
  title: 'First Step',
  description: 'Complete your first quest.',
  iconKey: 'footprint',
  trigger: AchievementTrigger.totalQuestCompletions,
  threshold: 1,
  rewardXp: 20,
  sortOrder: 0,
);

const _secondAchievement = Achievement(
  id: 'getting_started',
  title: 'Getting Started',
  description: 'Complete 5 quests.',
  iconKey: 'flag',
  trigger: AchievementTrigger.totalQuestCompletions,
  threshold: 5,
  rewardXp: 30,
  sortOrder: 1,
);

const _hiddenAchievement = Achievement(
  id: 'challenger',
  title: 'Challenger',
  description: 'Complete a Hard or Very Hard quest.',
  iconKey: 'shield',
  trigger: AchievementTrigger.hardOrAboveQuestCompleted,
  threshold: 1,
  hiddenUntilUnlocked: true,
  rewardXp: 30,
  sortOrder: 2,
);

XpTransaction _questTransaction(
  String questId,
  String dateKey,
  int repeatIndex,
) {
  final sourceId = '$questId|$dateKey|$repeatIndex';
  return XpTransaction(
    id: '$sourceId|health',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: AttributeType.health,
    baseXp: 100,
    modifiersApplied: const {'difficulty': 1.0},
    finalXp: 100,
    createdAt: DateTime.utc(2026, 1, 10),
    idempotencyKey: '$sourceId|health',
  );
}

void main() {
  late _FakeXpLedgerRepository ledger;
  late _FakeAchievementUnlockRepository unlockRepository;

  EvaluateAndUnlockAchievementsUseCase buildUseCase({
    List<Achievement> catalog = const [_oneShotAchievement, _secondAchievement],
  }) {
    final service = AchievementEvaluationService(
      xpLedgerRepository: ledger,
      unlockRepository: unlockRepository,
      catalog: catalog,
    );
    return EvaluateAndUnlockAchievementsUseCase(
      evaluationService: service,
      unlockRepository: unlockRepository,
      xpLedgerRepository: ledger,
      clock: _FakeClock(DateTime.utc(2026, 1, 10, 9)),
    );
  }

  setUp(() {
    ledger = _FakeXpLedgerRepository();
    unlockRepository = _FakeAchievementUnlockRepository();
  });

  test(
    'unlocks a newly-eligible achievement and grants its reward XP',
    () async {
      ledger.addFirstCompletion();
      final useCase = buildUseCase();

      final result = await useCase.execute();

      expect(result, isA<Ok<List<Achievement>>>());
      final unlocked = (result as Ok<List<Achievement>>).value;
      expect(unlocked.map((a) => a.id), ['first_step']);
      expect(await unlockRepository.isUnlocked('first_step'), isTrue);
      expect(await ledger.sumLifetimeXp(), 120); // 100 quest XP + 20 reward
    },
  );

  test(
    'reward XP is idempotent — evaluating again never grants it twice',
    () async {
      ledger.addFirstCompletion();
      final useCase = buildUseCase();

      await useCase.execute();
      final second = await useCase.execute();

      expect((second as Ok<List<Achievement>>).value, isEmpty); // nothing new
      expect(await ledger.sumLifetimeXp(), 120); // unchanged
      expect(
        ledger.byKey.values
            .where((t) => t.sourceType == XpSourceType.achievement)
            .length,
        1,
      );
    },
  );

  test(
    'duplicate evaluation never unlocks the same achievement twice',
    () async {
      ledger.addFirstCompletion();
      final useCase = buildUseCase();

      await useCase.execute();
      await useCase.execute();
      await useCase.execute();

      final unlocks = await unlockRepository.getAll();
      expect(unlocks.where((u) => u.achievementId == 'first_step').length, 1);
    },
  );

  test(
    'one evaluation pass can unlock multiple achievements at once',
    () async {
      for (var i = 0; i < 5; i++) {
        ledger.byKey.addAll({
          for (final t in [_questTransaction('q$i', '2026-01-1$i', 0)])
            t.idempotencyKey: t,
        });
      }
      final useCase = buildUseCase();

      final result = await useCase.execute();

      final unlocked = (result as Ok<List<Achievement>>).value;
      expect(unlocked.map((a) => a.id).toSet(), {
        'first_step',
        'getting_started',
      });
    },
  );

  test(
    'a reward that pushes past another threshold cascades safely in one call, '
    'bounded by the catalog size',
    () async {
      // 4 completions at 100 XP each = 400 quest XP. The first_step reward
      // (+20) alone wouldn't cross 5 completions, but getting_started is
      // keyed on *completion count*, not XP — so instead exercise a
      // lifetime-XP cascade: a small catalog where achievement A's reward
      // XP is what pushes lifetime XP past achievement B's threshold.
      const cascadeCatalog = [
        Achievement(
          id: 'a_completions',
          title: 'A',
          description: 'd',
          iconKey: 'star',
          trigger: AchievementTrigger.totalQuestCompletions,
          threshold: 1,
          rewardXp: 50,
          sortOrder: 0,
        ),
        Achievement(
          id: 'b_xp',
          title: 'B',
          description: 'd',
          iconKey: 'star',
          trigger: AchievementTrigger.lifetimeXpReached,
          threshold: 140, // 100 (quest) + 50 (A's reward) crosses this
          sortOrder: 1,
        ),
      ];
      ledger.addFirstCompletion();
      final useCase = buildUseCase(catalog: cascadeCatalog);

      final result = await useCase.execute();

      final unlocked = (result as Ok<List<Achievement>>).value;
      expect(unlocked.map((a) => a.id).toSet(), {'a_completions', 'b_xp'});
      expect(await unlockRepository.isUnlocked('b_xp'), isTrue);
    },
  );

  test(
    'hidden achievements unlock and persist the same as any other',
    () async {
      ledger.byKey.addAll({
        for (final t in [
          XpTransaction(
            id: 'q1|2026-01-10|0|health',
            sourceType: XpSourceType.quest,
            sourceId: 'q1|2026-01-10|0',
            attribute: AttributeType.health,
            baseXp: 100,
            modifiersApplied: const {'difficulty': 1.6},
            finalXp: 160,
            createdAt: DateTime.utc(2026, 1, 10),
            idempotencyKey: 'q1|2026-01-10|0|health',
          ),
        ])
          t.idempotencyKey: t,
      });
      final useCase = buildUseCase(catalog: const [_hiddenAchievement]);

      final result = await useCase.execute();

      final unlocked = (result as Ok<List<Achievement>>).value;
      expect(unlocked.single.id, 'challenger');
      expect(await unlockRepository.isUnlocked('challenger'), isTrue);
    },
  );

  test('ledger write happens before the unlock write — a failure writing the '
      'unlock record leaves the reward already granted, and a retry '
      'completes the unlock without granting the reward again', () async {
    ledger.addFirstCompletion();
    unlockRepository.appendAllError = Exception('disk full');
    final useCase = buildUseCase();

    final failed = await useCase.execute();
    expect(failed, isA<Err<List<Achievement>>>());
    expect(await ledger.sumLifetimeXp(), 120); // reward already written
    expect(await unlockRepository.isUnlocked('first_step'), isFalse);

    unlockRepository.appendAllError = null;
    final retried = await useCase.execute();

    expect((retried as Ok<List<Achievement>>).value.map((a) => a.id), [
      'first_step',
    ]);
    expect(await unlockRepository.isUnlocked('first_step'), isTrue);
    expect(await ledger.sumLifetimeXp(), 120); // never granted twice
  });

  test(
    'no eligible achievements returns an empty list without writing anything',
    () async {
      final useCase = buildUseCase();

      final result = await useCase.execute();

      expect((result as Ok<List<Achievement>>).value, isEmpty);
      expect(ledger.appendAllCallCount, 0);
      expect(unlockRepository.appendAllCallCount, 0);
    },
  );
}

extension on _FakeXpLedgerRepository {
  /// One quest completion worth exactly 100 XP — enough to satisfy
  /// `first_step` (threshold 1) but not `getting_started` (threshold 5).
  void addFirstCompletion() {
    final t = XpTransaction(
      id: 'q1|2026-01-10|0|health',
      sourceType: XpSourceType.quest,
      sourceId: 'q1|2026-01-10|0',
      attribute: AttributeType.health,
      baseXp: 100,
      modifiersApplied: const {'difficulty': 1.0},
      finalXp: 100,
      createdAt: DateTime.utc(2026, 1, 10),
      idempotencyKey: 'q1|2026-01-10|0|health',
    );
    byKey[t.idempotencyKey] = t;
  }
}
