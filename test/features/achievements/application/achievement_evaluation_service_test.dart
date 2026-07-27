import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/achievements/application/services/achievement_evaluation_service.dart';
import 'package:prime/features/achievements/domain/entities/achievement.dart';
import 'package:prime/features/achievements/domain/entities/achievement_trigger.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';
import 'package:prime/features/achievements/domain/repositories/achievement_unlock_repository.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/domain/repositories/xp_ledger_repository.dart';

class _FakeXpLedgerRepository implements XpLedgerRepository {
  final List<XpTransaction> all = [];

  @override
  Future<void> appendAll(List<XpTransaction> transactions) async =>
      all.addAll(transactions);

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
  Future<List<XpTransaction>> getAll() async => List.of(all);

  @override
  Future<int> sumLifetimeXp() async =>
      all.fold<int>(0, (sum, t) => sum + t.finalXp);

  @override
  Future<int> sumXpForAttribute(AttributeType type) async => all
      .where((t) => t.attribute == type)
      .fold<int>(0, (sum, t) => sum + t.finalXp);
}

class _FakeAchievementUnlockRepository implements AchievementUnlockRepository {
  final Map<String, AchievementUnlock> unlocks = {};

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
    for (final unlock in newUnlocks) {
      unlocks.putIfAbsent(unlock.achievementId, () => unlock);
    }
  }
}

/// One quest-completion's worth of ledger rows — a single attribute row is
/// enough for these tests (multi-attribute allocation is
/// `QuestXpCalculator`'s concern, already covered elsewhere).
XpTransaction _questTransaction({
  required String questId,
  required String dateKey,
  int repeatIndex = 0,
  AttributeType attribute = AttributeType.health,
  int finalXp = 100,
  double difficulty = 1.0,
}) {
  final sourceId = '$questId|$dateKey|$repeatIndex';
  return XpTransaction(
    id: '$sourceId|${attribute.name}',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: attribute,
    baseXp: finalXp,
    modifiersApplied: {'difficulty': difficulty},
    finalXp: finalXp,
    createdAt: DateTime.utc(2026, 1, 10),
    idempotencyKey: '$sourceId|${attribute.name}',
  );
}

XpTransaction _achievementRewardTransaction({
  required String achievementId,
  AttributeType attribute = AttributeType.discipline,
  int finalXp = 20,
}) {
  final sourceId = '$achievementId|reward';
  return XpTransaction(
    id: sourceId,
    sourceType: XpSourceType.achievement,
    sourceId: sourceId,
    attribute: attribute,
    baseXp: finalXp,
    modifiersApplied: const {},
    finalXp: finalXp,
    createdAt: DateTime.utc(2026, 1, 10),
    idempotencyKey: sourceId,
  );
}

void main() {
  late _FakeXpLedgerRepository ledger;
  late _FakeAchievementUnlockRepository unlockRepository;
  late AchievementEvaluationService service;

  setUp(() {
    ledger = _FakeXpLedgerRepository();
    unlockRepository = _FakeAchievementUnlockRepository();
    service = AchievementEvaluationService(
      xpLedgerRepository: ledger,
      unlockRepository: unlockRepository,
      catalog: const [
        Achievement(
          id: 'a1',
          title: 'A1',
          description: 'd1',
          iconKey: 'star',
          trigger: AchievementTrigger.totalQuestCompletions,
          threshold: 1,
          sortOrder: 0,
        ),
        Achievement(
          id: 'a2',
          title: 'A2',
          description: 'd2',
          iconKey: 'star',
          trigger: AchievementTrigger.totalQuestCompletions,
          threshold: 3,
          sortOrder: 1,
        ),
      ],
    );
  });

  group('buildSnapshot', () {
    test(
      'totalQuestCompletions counts distinct completion events only',
      () async {
        ledger.all.addAll([
          _questTransaction(
            questId: 'q1',
            dateKey: '2026-01-10',
            repeatIndex: 0,
          ),
          _questTransaction(
            questId: 'q1',
            dateKey: '2026-01-10',
            repeatIndex: 1,
          ), // a same-day repeat: a second, distinct completion event
        ]);

        final snapshot = await service.buildSnapshot();
        expect(snapshot.totalQuestCompletions, 2);
      },
    );

    test(
      'achievement reward transactions never count as quest completions',
      () async {
        ledger.all.addAll([
          _questTransaction(questId: 'q1', dateKey: '2026-01-10'),
          _achievementRewardTransaction(achievementId: 'a1'),
        ]);

        final snapshot = await service.buildSnapshot();
        expect(snapshot.totalQuestCompletions, 1);
      },
    );

    test(
      'lifetimeXp and xpByAttribute include achievement reward XP',
      () async {
        ledger.all.addAll([
          _questTransaction(
            questId: 'q1',
            dateKey: '2026-01-10',
            attribute: AttributeType.health,
            finalXp: 100,
          ),
          _achievementRewardTransaction(
            achievementId: 'a1',
            attribute: AttributeType.discipline,
            finalXp: 20,
          ),
        ]);

        final snapshot = await service.buildSnapshot();
        expect(snapshot.lifetimeXp, 120);
        expect(snapshot.xpByAttribute[AttributeType.health], 100);
        expect(snapshot.xpByAttribute[AttributeType.discipline], 20);
      },
    );

    test(
      'playerLevel is derived from lifetimeXp via the level curve',
      () async {
        // xpToNext(1, base: 100) = floor(100 * 1^1.5) = 100 — 100 XP reaches
        // level 2 exactly.
        ledger.all.add(
          _questTransaction(questId: 'q1', dateKey: '2026-01-10', finalXp: 100),
        );
        final snapshot = await service.buildSnapshot();
        expect(snapshot.playerLevel, 2);
      },
    );

    test(
      'hardOrAboveCompletionCount counts distinct hard-or-above completions',
      () async {
        ledger.all.addAll([
          _questTransaction(
            questId: 'q1',
            dateKey: '2026-01-10',
            difficulty: 1.3, // Hard
          ),
          _questTransaction(
            questId: 'q2',
            dateKey: '2026-01-10',
            difficulty: 1.6, // Very Hard
          ),
          _questTransaction(
            questId: 'q3',
            dateKey: '2026-01-10',
            difficulty: 1.0, // Normal — not hard-or-above
          ),
        ]);

        final snapshot = await service.buildSnapshot();
        expect(snapshot.hardOrAboveCompletionCount, 2);
      },
    );

    test(
      'longestConsecutiveCompletionDayStreak finds the longest run',
      () async {
        ledger.all.addAll([
          _questTransaction(questId: 'q1', dateKey: '2026-01-05'),
          _questTransaction(questId: 'q1', dateKey: '2026-01-06'),
          _questTransaction(questId: 'q1', dateKey: '2026-01-07'),
          // A gap, then an isolated day.
          _questTransaction(questId: 'q1', dateKey: '2026-01-09'),
        ]);

        final snapshot = await service.buildSnapshot();
        expect(snapshot.longestConsecutiveCompletionDayStreak, 3);
      },
    );

    test('an empty ledger produces an all-zero snapshot', () async {
      final snapshot = await service.buildSnapshot();
      expect(snapshot.totalQuestCompletions, 0);
      expect(snapshot.lifetimeXp, 0);
      expect(snapshot.playerLevel, 1);
      expect(snapshot.hardOrAboveCompletionCount, 0);
      expect(snapshot.longestConsecutiveCompletionDayStreak, 0);
    });
  });

  group('evaluateEligible', () {
    test(
      'returns catalog entries whose criteria are met and not yet unlocked',
      () async {
        ledger.all.add(_questTransaction(questId: 'q1', dateKey: '2026-01-10'));

        final eligible = await service.evaluateEligible();
        expect(eligible.map((a) => a.id), ['a1']); // only threshold-1 met
      },
    );

    test(
      'already-unlocked achievements are excluded even if still eligible',
      () async {
        ledger.all.add(_questTransaction(questId: 'q1', dateKey: '2026-01-10'));
        unlockRepository.unlocks['a1'] = AchievementUnlock(
          achievementId: 'a1',
          unlockedAt: DateTime.utc(2026, 1, 1),
        );

        final eligible = await service.evaluateEligible();
        expect(eligible, isEmpty);
      },
    );

    test('results are sorted by sortOrder', () async {
      ledger.all.addAll([
        _questTransaction(questId: 'q1', dateKey: '2026-01-10', repeatIndex: 0),
        _questTransaction(questId: 'q1', dateKey: '2026-01-10', repeatIndex: 1),
        _questTransaction(questId: 'q1', dateKey: '2026-01-10', repeatIndex: 2),
      ]);

      final eligible = await service.evaluateEligible();
      expect(eligible.map((a) => a.id).toList(), ['a1', 'a2']);
    });
  });
}
