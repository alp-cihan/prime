import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/quests/application/clock.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/application/models/complete_quest_result.dart';
import 'package:prime/features/quests/application/use_cases/complete_quest_use_case.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/domain/repositories/quest_progress_repository.dart';
import 'package:prime/features/quests/domain/repositories/quest_repository.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/domain/repositories/xp_ledger_repository.dart';

class _FakeQuestRepository implements QuestRepository {
  _FakeQuestRepository([Quest? initial]) {
    if (initial != null) quests[initial.id] = initial;
  }

  final Map<String, Quest> quests = {};

  @override
  Future<List<Quest>> getAll() async => quests.values.toList();

  @override
  Future<Quest?> getById(String id) async => quests[id];

  @override
  Stream<List<Quest>> watchAll() => Stream.value(quests.values.toList());

  @override
  Future<void> upsert(Quest quest) async => quests[quest.id] = quest;
}

class _FakeQuestProgressRepository implements QuestProgressRepository {
  final List<QuestProgress> entries = [];

  @override
  Future<QuestProgress?> getForQuestAndDate(
    String questId,
    DateTime date,
  ) async {
    for (final entry in entries) {
      if (entry.questId == questId && _sameDate(entry.date, date)) return entry;
    }
    return null;
  }

  @override
  Future<List<QuestProgress>> getForQuest(String questId) async =>
      entries.where((e) => e.questId == questId).toList();

  @override
  Future<void> upsert(QuestProgress progress) async {
    entries.removeWhere(
      (e) => e.questId == progress.questId && _sameDate(e.date, progress.date),
    );
    entries.add(progress);
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Mirrors [CompleteQuestUseCase]'s `sourceId` format (`questId|dateKey|
/// repeatIndex`) purely so this fake can filter by date — a real Hive-backed
/// repository would index `(questId, date)` directly instead of parsing it
/// back out of `sourceId`.
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
  ) async {
    final prefix = '$questId|${_dateKey(date)}|';
    return byKey.values.where((t) => t.sourceId.startsWith(prefix)).toList();
  }

  @override
  Future<List<XpTransaction>> getAll() async => byKey.values.toList();

  @override
  Future<int> sumLifetimeXp() async =>
      byKey.values.fold<int>(0, (sum, t) => sum + t.finalXp);

  @override
  Future<int> sumXpForAttribute(AttributeType type) async => byKey.values
      .where((t) => t.attribute == type)
      .fold<int>(0, (sum, t) => sum + t.finalXp);

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;
}

Quest _buildQuest({
  String id = 'q1',
  QuestDifficulty difficulty = QuestDifficulty.normal,
  Map<AttributeType, int> weights = const {
    AttributeType.health: 60,
    AttributeType.strength: 40,
  },
  ProgressType progressType = ProgressType.binary,
  double targetProgress = 1,
  QuestCompletionState state = QuestCompletionState.notStarted,
}) {
  return Quest(
    id: id,
    title: 'Test quest',
    description: 'A quest used for testing',
    type: QuestType.daily,
    difficulty: difficulty,
    attributeXpWeights: weights,
    linkedIdentityStatementIds: const [],
    progressType: progressType,
    currentProgress: 0,
    targetProgress: targetProgress,
    prerequisiteQuestIds: const [],
    state: state,
    failureBehavior: FailureBehavior.expire,
  );
}

class _Harness {
  _Harness({Quest? quest})
    : questRepo = _FakeQuestRepository(quest),
      progressRepo = _FakeQuestProgressRepository(),
      ledgerRepo = _FakeXpLedgerRepository();

  final _FakeQuestRepository questRepo;
  final _FakeQuestProgressRepository progressRepo;
  final _FakeXpLedgerRepository ledgerRepo;

  CompleteQuestUseCase get useCase => CompleteQuestUseCase(
    questRepository: questRepo,
    questProgressRepository: progressRepo,
    xpLedgerRepository: ledgerRepo,
    clock: _FakeClock(DateTime.utc(2026, 1, 10, 9)),
  );
}

CompleteQuestResult _okValue(Result<CompleteQuestResult> result) {
  expect(result, isA<Ok<CompleteQuestResult>>());
  return (result as Ok<CompleteQuestResult>).value;
}

void main() {
  test(
    'successful first completion awards full XP with the first-completion bonus',
    () async {
      final quest = _buildQuest();
      final harness = _Harness(quest: quest);

      final result = await harness.useCase.execute(
        CompleteQuestCommand(
          questId: quest.id,
          date: DateTime.utc(2026, 1, 10),
          progressValue: 1,
        ),
      );

      final value = _okValue(result);
      expect(value.totalXpAwarded, 125); // round(100*1.0*1.0*1.0*1.0) * 1.25
      expect(value.firstCompletionBonusApplied, isTrue);
      expect(value.dailyCapLimited, isFalse);
      expect(value.progress.isComplete, isTrue);
      expect(value.transactions.length, 2);
    },
  );

  test(
    'firstCompletionBonus is applied only once, not on a later day',
    () async {
      final quest = _buildQuest();
      final harness = _Harness(quest: quest);

      final day1 = _okValue(
        await harness.useCase.execute(
          CompleteQuestCommand(
            questId: quest.id,
            date: DateTime.utc(2026, 1, 10),
            progressValue: 1,
          ),
        ),
      );
      expect(day1.firstCompletionBonusApplied, isTrue);

      final day2 = _okValue(
        await harness.useCase.execute(
          CompleteQuestCommand(
            questId: quest.id,
            date: DateTime.utc(2026, 1, 11),
            progressValue: 1,
          ),
        ),
      );
      expect(day2.firstCompletionBonusApplied, isFalse);
      expect(
        day2.totalXpAwarded,
        102,
      ); // round(100*1.0*1.0*1.02*1.0), streak=1 from day1
    },
  );

  test(
    'a second completion on the same day earns diminished, additional XP',
    () async {
      final quest = _buildQuest();
      final harness = _Harness(quest: quest);
      final date = DateTime.utc(2026, 1, 10);

      final first = _okValue(
        await harness.useCase.execute(
          CompleteQuestCommand(questId: quest.id, date: date, progressValue: 1),
        ),
      );
      expect(first.totalXpAwarded, 125);

      final second = _okValue(
        await harness.useCase.execute(
          CompleteQuestCommand(questId: quest.id, date: date, progressValue: 1),
        ),
      );
      expect(second.firstCompletionBonusApplied, isFalse);
      expect(
        second.totalXpAwarded,
        50,
      ); // round(100) * 0.5 diminishing, well under the 200 cap
    },
  );

  test('daily cap already reached produces zero additional XP', () async {
    final quest = _buildQuest();
    final harness = _Harness(quest: quest);
    final date = DateTime.utc(2026, 1, 10);

    Future<CompleteQuestResult> completeOnce() async => _okValue(
      await harness.useCase.execute(
        CompleteQuestCommand(questId: quest.id, date: date, progressValue: 1),
      ),
    );

    final r1 = await completeOnce(); // 125, cumulative 125
    final r2 = await completeOnce(); // 50, cumulative 175
    final r3 = await completeOnce(); // 25, cumulative 200 (cap reached exactly)
    final r4 = await completeOnce(); // cap already spent -> 0

    expect(r1.totalXpAwarded, 125);
    expect(r2.totalXpAwarded, 50);
    expect(r3.totalXpAwarded, 25);
    expect(r4.totalXpAwarded, 0);
    expect(r4.dailyCapLimited, isTrue);
    expect(r4.xpByAttribute.values, everyElement(0));
    expect(
      r4.progress.isComplete,
      isTrue,
    ); // still "done" today, just no more XP
  });

  test(
    'a partial completion ratio scales XP proportionally for quantity quests',
    () async {
      final quest = _buildQuest(
        weights: {AttributeType.knowledge: 100},
        progressType: ProgressType.quantity,
        targetProgress: 60,
      );
      final harness = _Harness(quest: quest);

      final result = _okValue(
        await harness.useCase.execute(
          CompleteQuestCommand(
            questId: quest.id,
            date: DateTime.utc(2026, 1, 10),
            progressValue: 30,
          ),
        ),
      );

      // ratio=0.5: round(100*1.0*0.5*1.0*1.0)=50, *1.25 firstCompletionBonus = 62.5 -> round = 63
      expect(result.totalXpAwarded, 63);
      expect(result.progress.isComplete, isFalse);
      expect(result.progress.progressValue, 30);
    },
  );

  test(
    'quality rating and consistency streak both flow into the final XP',
    () async {
      final quest = _buildQuest(weights: {AttributeType.mindfulness: 100});
      final harness = _Harness(quest: quest);

      await harness.useCase.execute(
        CompleteQuestCommand(
          questId: quest.id,
          date: DateTime.utc(2026, 1, 8),
          progressValue: 1,
        ),
      );
      await harness.useCase.execute(
        CompleteQuestCommand(
          questId: quest.id,
          date: DateTime.utc(2026, 1, 9),
          progressValue: 1,
        ),
      );
      final result = _okValue(
        await harness.useCase.execute(
          CompleteQuestCommand(
            questId: quest.id,
            date: DateTime.utc(2026, 1, 10),
            progressValue: 1,
            qualityRating: 5,
          ),
        ),
      );

      // streak=2 -> consistency=1.04; quality 5 stars -> 1.2; no bonus (day 1 already had it); no diminishing.
      // round(100 * 1.0 * 1.0 * 1.04 * 1.2) = round(124.8) = 125
      expect(result.totalXpAwarded, 125);
    },
  );

  test(
    'idempotency keys and transaction ids are deterministic given the same inputs',
    () async {
      final quest = _buildQuest();
      final command = CompleteQuestCommand(
        questId: quest.id,
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
      );

      final first = _okValue(
        await _Harness(quest: quest).useCase.execute(command),
      );
      final second = _okValue(
        await _Harness(quest: quest).useCase.execute(command),
      );

      expect(
        first.transactions.map((t) => t.idempotencyKey).toSet(),
        second.transactions.map((t) => t.idempotencyKey).toSet(),
      );
      expect(
        first.transactions.map((t) => t.id).toSet(),
        second.transactions.map((t) => t.id).toSet(),
      );
      expect(first.transactions.map((t) => t.idempotencyKey).toSet(), {
        'q1|health|2026-01-10|0',
        'q1|strength|2026-01-10|0',
      });
    },
  );

  test(
    'retrying an append with already-recorded transactions does not duplicate ledger XP',
    () async {
      final quest = _buildQuest();
      final harness = _Harness(quest: quest);

      final result = _okValue(
        await harness.useCase.execute(
          CompleteQuestCommand(
            questId: quest.id,
            date: DateTime.utc(2026, 1, 10),
            progressValue: 1,
          ),
        ),
      );
      final totalBefore = await harness.ledgerRepo.sumLifetimeXp();

      // Simulate an at-least-once retry resending the exact transactions already written.
      await harness.ledgerRepo.appendAll(result.transactions);

      final totalAfter = await harness.ledgerRepo.sumLifetimeXp();
      expect(totalAfter, totalBefore);
      expect(harness.ledgerRepo.byKey.length, result.transactions.length);
    },
  );

  test('rejects a missing quest', () async {
    final harness = _Harness();

    final result = await harness.useCase.execute(
      CompleteQuestCommand(
        questId: 'missing',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
      ),
    );

    expect(result, isA<Err<CompleteQuestResult>>());
    expect(
      (result as Err<CompleteQuestResult>).failure,
      isA<NotFoundFailure>(),
    );
  });

  test('rejects completion of an expired quest', () async {
    final quest = _buildQuest(state: QuestCompletionState.expired);
    final harness = _Harness(quest: quest);

    final result = await harness.useCase.execute(
      CompleteQuestCommand(
        questId: quest.id,
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
      ),
    );

    expect(result, isA<Err<CompleteQuestResult>>());
    expect(
      (result as Err<CompleteQuestResult>).failure,
      isA<InvalidStateFailure>(),
    );
  });

  test('propagates the calculator ValidationFailure unchanged', () async {
    final quest = _buildQuest();
    final harness = _Harness(quest: quest);

    final result = await harness.useCase.execute(
      CompleteQuestCommand(
        questId: quest.id,
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        qualityRating: 6,
      ),
    );

    expect(result, isA<Err<CompleteQuestResult>>());
    expect(
      (result as Err<CompleteQuestResult>).failure,
      isA<ValidationFailure>(),
    );
  });

  test('does not write QuestProgress when the completion fails', () async {
    final quest = _buildQuest();
    final harness = _Harness(quest: quest);

    await harness.useCase.execute(
      CompleteQuestCommand(
        questId: quest.id,
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        qualityRating: 6,
      ),
    );

    expect(harness.progressRepo.entries, isEmpty);
  });

  test('does not write XP transactions when the completion fails', () async {
    final quest = _buildQuest();
    final harness = _Harness(quest: quest);

    await harness.useCase.execute(
      CompleteQuestCommand(
        questId: quest.id,
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        qualityRating: 6,
      ),
    );

    expect(harness.ledgerRepo.byKey, isEmpty);
  });

  test('the sum of created transactions equals the returned total', () async {
    final quest = _buildQuest(
      weights: {
        AttributeType.health: 70,
        AttributeType.strength: 40,
        AttributeType.discipline: 25,
      },
    );
    final harness = _Harness(quest: quest);

    final result = _okValue(
      await harness.useCase.execute(
        CompleteQuestCommand(
          questId: quest.id,
          date: DateTime.utc(2026, 1, 10),
          progressValue: 1,
        ),
      ),
    );

    final sum = result.transactions.fold<int>(0, (s, t) => s + t.finalXp);
    expect(sum, result.totalXpAwarded);
  });

  test(
    "each transaction's finalXp matches the returned per-attribute allocation, and baseXp is the original weight",
    () async {
      final quest = _buildQuest(
        weights: {
          AttributeType.health: 70,
          AttributeType.strength: 40,
          AttributeType.discipline: 25,
        },
      );
      final harness = _Harness(quest: quest);

      final result = _okValue(
        await harness.useCase.execute(
          CompleteQuestCommand(
            questId: quest.id,
            date: DateTime.utc(2026, 1, 10),
            progressValue: 1,
          ),
        ),
      );

      for (final transaction in result.transactions) {
        expect(
          transaction.finalXp,
          result.xpByAttribute[transaction.attribute],
        );
        expect(
          transaction.baseXp,
          quest.attributeXpWeights[transaction.attribute],
        );
      }
    },
  );
}
