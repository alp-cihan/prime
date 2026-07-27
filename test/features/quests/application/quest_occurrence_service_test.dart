import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/application/services/quest_occurrence_service.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/domain/repositories/xp_ledger_repository.dart';

/// Minimal in-memory [XpLedgerRepository] fake — enough for
/// [QuestOccurrenceService], which only ever calls [getTransactionsForQuest].
/// Mirrors the `sourceId` format `CompleteQuestUseCase` actually produces
/// (`questId|dateKey|repeatIndex`), since the service parses dates back out
/// of it via `HiveKeys.dateFromSourceId`.
class _FakeXpLedgerRepository implements XpLedgerRepository {
  final List<XpTransaction> all = [];

  @override
  Future<void> appendAll(List<XpTransaction> transactions) async {
    all.addAll(transactions);
  }

  @override
  Future<List<XpTransaction>> getTransactionsForQuestAndDate(
    String questId,
    DateTime date,
  ) async => throw UnimplementedError();

  @override
  Future<List<XpTransaction>> getTransactionsForQuest(String questId) async =>
      all.where((t) => t.sourceId.startsWith('$questId|')).toList();

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

/// One synthetic ledger row exactly as `CompleteQuestUseCase` would write it
/// for a single-attribute completion.
XpTransaction _transaction({
  required String questId,
  required String dateKey,
  required int repeatIndex,
  int finalXp = 100,
}) {
  final sourceId = '$questId|$dateKey|$repeatIndex';
  return XpTransaction(
    id: '$sourceId|health',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: AttributeType.health,
    baseXp: finalXp,
    modifiersApplied: const {},
    finalXp: finalXp,
    createdAt: DateTime.utc(2026, 1, 10),
    idempotencyKey: '$questId|health|$dateKey|$repeatIndex',
  );
}

Quest _quest(Repeatability repeatability) => Quest(
  id: 'q1',
  title: 'Test',
  description: '',
  type: QuestType.daily,
  difficulty: QuestDifficulty.normal,
  attributeXpWeights: const {AttributeType.health: 100},
  linkedIdentityStatementIds: const [],
  progressType: ProgressType.binary,
  currentProgress: 0,
  targetProgress: 1,
  prerequisiteQuestIds: const [],
  state: QuestCompletionState.notStarted,
  failureBehavior: FailureBehavior.expire,
  repeatability: repeatability,
);

void main() {
  group('Repeatability.none', () {
    test('eligible and first-completion-ever with no ledger history', () async {
      final ledger = _FakeXpLedgerRepository();
      final service = QuestOccurrenceService(xpLedgerRepository: ledger);

      final status = await service.resolve(
        quest: _quest(Repeatability.none),
        instant: DateTime.utc(2026, 1, 10),
      );

      expect(status.eligible, isTrue);
      expect(status.isFirstCompletionEver, isTrue);
      expect(status.repeatIndex, 0);
      expect(status.priorXpEarnedInOccurrence, 0);
    });

    test('ineligible forever once any ledger entry exists', () async {
      final ledger = _FakeXpLedgerRepository()
        ..all.add(
          _transaction(questId: 'q1', dateKey: '2026-01-10', repeatIndex: 0),
        );
      final service = QuestOccurrenceService(xpLedgerRepository: ledger);

      final sameDay = await service.resolve(
        quest: _quest(Repeatability.none),
        instant: DateTime.utc(2026, 1, 10),
      );
      final muchLater = await service.resolve(
        quest: _quest(Repeatability.none),
        instant: DateTime.utc(2027, 6, 1),
      );

      expect(sameDay.eligible, isFalse);
      expect(muchLater.eligible, isFalse);
      expect(muchLater.isFirstCompletionEver, isFalse);
    });
  });

  group('Repeatability.daily', () {
    test('repeat index counts only same-day entries', () async {
      final ledger = _FakeXpLedgerRepository()
        ..all.addAll([
          _transaction(questId: 'q1', dateKey: '2026-01-10', repeatIndex: 0),
          _transaction(questId: 'q1', dateKey: '2026-01-10', repeatIndex: 1),
          _transaction(questId: 'q1', dateKey: '2026-01-09', repeatIndex: 0),
        ]);
      final service = QuestOccurrenceService(xpLedgerRepository: ledger);

      final status = await service.resolve(
        quest: _quest(Repeatability.daily),
        instant: DateTime.utc(2026, 1, 10),
      );

      expect(status.eligible, isTrue);
      expect(status.repeatIndex, 2); // the two 2026-01-10 rows
      expect(status.priorXpEarnedInOccurrence, 200);
      expect(status.isFirstCompletionEver, isFalse);
    });

    test('a new day is always eligible with a fresh repeat index', () async {
      final ledger = _FakeXpLedgerRepository()
        ..all.add(
          _transaction(questId: 'q1', dateKey: '2026-01-10', repeatIndex: 0),
        );
      final service = QuestOccurrenceService(xpLedgerRepository: ledger);

      final status = await service.resolve(
        quest: _quest(Repeatability.daily),
        instant: DateTime.utc(2026, 1, 11),
      );

      expect(status.eligible, isTrue);
      expect(status.repeatIndex, 0);
      expect(status.priorXpEarnedInOccurrence, 0);
    });
  });

  group('Repeatability.weekly', () {
    test('repeat index and prior XP are pooled across the whole ISO week, not '
        'just the literal day', () async {
      final ledger = _FakeXpLedgerRepository()
        ..all.addAll([
          // Monday 2026-01-05 and Wednesday 2026-01-07 are the same ISO
          // week (2026-W02).
          _transaction(questId: 'q1', dateKey: '2026-01-05', repeatIndex: 0),
          _transaction(questId: 'q1', dateKey: '2026-01-07', repeatIndex: 1),
        ]);
      final service = QuestOccurrenceService(xpLedgerRepository: ledger);

      final status = await service.resolve(
        quest: _quest(Repeatability.weekly),
        instant: DateTime.utc(2026, 1, 9), // Friday, same week
      );

      expect(status.eligible, isTrue);
      expect(status.repeatIndex, 2);
      expect(status.priorXpEarnedInOccurrence, 200);
    });

    test(
      'a genuinely new ISO week does not see the prior week\'s entries',
      () async {
        final ledger = _FakeXpLedgerRepository()
          ..all.addAll([
            _transaction(questId: 'q1', dateKey: '2026-01-05', repeatIndex: 0),
            _transaction(questId: 'q1', dateKey: '2026-01-07', repeatIndex: 1),
          ]);
        final service = QuestOccurrenceService(xpLedgerRepository: ledger);

        final status = await service.resolve(
          quest: _quest(Repeatability.weekly),
          instant: DateTime.utc(2026, 1, 12), // next Monday
        );

        expect(status.eligible, isTrue);
        expect(status.repeatIndex, 0);
        expect(status.priorXpEarnedInOccurrence, 0);
        expect(status.isFirstCompletionEver, isFalse); // ledger has history
      },
    );

    test(
      'occurrence anchor/key for the resolved instant come straight from the '
      'policy — the week\'s Monday and its ISO key',
      () async {
        final ledger = _FakeXpLedgerRepository();
        final service = QuestOccurrenceService(xpLedgerRepository: ledger);

        final status = await service.resolve(
          quest: _quest(Repeatability.weekly),
          instant: DateTime.utc(2026, 1, 9), // Friday
        );

        expect(status.occurrence.anchorDate, DateTime.utc(2026, 1, 5));
        expect(status.occurrence.key, '2026-W02');
      },
    );
  });
}
