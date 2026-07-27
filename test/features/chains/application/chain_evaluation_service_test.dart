import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/chains/application/services/chain_evaluation_service.dart';
import 'package:prime/features/chains/domain/entities/chain.dart';
import 'package:prime/features/chains/domain/entities/chain_progress.dart';
import 'package:prime/features/chains/domain/repositories/chain_progress_repository.dart';
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

class _FakeChainProgressRepository implements ChainProgressRepository {
  final Map<String, ChainProgress> progress = {};

  @override
  Future<ChainProgress?> getForChain(String chainId) async => progress[chainId];

  @override
  Future<List<ChainProgress>> getAll() async => progress.values.toList();

  @override
  Stream<List<ChainProgress>> watchAll() =>
      Stream.value(progress.values.toList());

  @override
  Future<void> upsert(ChainProgress value) async =>
      progress[value.chainId] = value;
}

XpTransaction _questCompletion(
  String questId, {
  AttributeType attribute = AttributeType.health,
}) {
  final sourceId = '$questId|2026-01-10|0';
  return XpTransaction(
    id: '$sourceId|${attribute.name}',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: attribute,
    baseXp: 100,
    modifiersApplied: const {'difficulty': 1.0},
    finalXp: 100,
    createdAt: DateTime.utc(2026, 1, 10),
    idempotencyKey: '$sourceId|${attribute.name}',
  );
}

XpTransaction _achievementReward(String achievementId) {
  final sourceId = '$achievementId|reward';
  return XpTransaction(
    id: sourceId,
    sourceType: XpSourceType.achievement,
    sourceId: sourceId,
    attribute: AttributeType.discipline,
    baseXp: 20,
    modifiersApplied: const {},
    finalXp: 20,
    createdAt: DateTime.utc(2026, 1, 10),
    idempotencyKey: sourceId,
  );
}

void main() {
  late _FakeXpLedgerRepository ledger;
  late _FakeChainProgressRepository progressRepository;
  late ChainEvaluationService service;

  setUp(() {
    ledger = _FakeXpLedgerRepository();
    progressRepository = _FakeChainProgressRepository();
    service = ChainEvaluationService(
      xpLedgerRepository: ledger,
      progressRepository: progressRepository,
    );
  });

  group('completedQuestIds', () {
    test('recovers quest ids from quest-sourced ledger rows only', () async {
      ledger.all.addAll([
        _questCompletion('q1'),
        _achievementReward('first_step'),
      ]);

      final ids = await service.completedQuestIds();

      expect(ids, {'q1'});
    });

    test('is empty with no ledger history', () async {
      expect(await service.completedQuestIds(), isEmpty);
    });
  });

  group('evaluate', () {
    final chain = Chain(
      id: 'chain1',
      title: 'Chain',
      description: 'desc',
      iconKey: 'book',
      questIds: const ['q1', 'q2', 'q3'],
      sortOrder: 0,
    );

    test(
      'does not advance if the current stage quest is not yet completed',
      () async {
        final result = await service.evaluate(
          chain,
          completedQuestIds: const {},
          instant: DateTime.utc(2026, 1, 10),
        );

        expect(result.advanced, isFalse);
        expect(result.progress.completedStageCount, 0);
      },
    );

    test('advances one stage when its quest is completed', () async {
      final result = await service.evaluate(
        chain,
        completedQuestIds: {'q1'},
        instant: DateTime.utc(2026, 1, 10),
      );

      expect(result.advanced, isTrue);
      expect(result.progress.completedStageCount, 1);
      expect(result.newlyCompleted, isFalse);
    });

    test(
      'catches up through multiple already-satisfied stages in one call',
      () async {
        final result = await service.evaluate(
          chain,
          completedQuestIds: {'q1', 'q2', 'q3'},
          instant: DateTime.utc(2026, 1, 10),
        );

        expect(result.progress.completedStageCount, 3);
        expect(result.newlyCompleted, isTrue);
        expect(result.progress.completedAt, DateTime.utc(2026, 1, 10));
      },
    );

    test('stops advancing at the first not-yet-completed stage', () async {
      final result = await service.evaluate(
        chain,
        completedQuestIds: {'q1', 'q3'}, // q2 missing — q3 must not count
        instant: DateTime.utc(2026, 1, 10),
      );

      expect(result.progress.completedStageCount, 1);
    });

    test('a chain already marked completedAt is never re-evaluated', () async {
      await progressRepository.upsert(
        ChainProgress(
          chainId: 'chain1',
          completedStageCount: 3,
          completedAt: DateTime.utc(2025, 1, 1),
        ),
      );

      final result = await service.evaluate(
        chain,
        completedQuestIds: {'q1', 'q2', 'q3'},
        instant: DateTime.utc(2026, 1, 10),
      );

      expect(result.advanced, isFalse);
      expect(result.newlyCompleted, isFalse);
      expect(
        result.progress.completedAt,
        DateTime.utc(2025, 1, 1),
      ); // unchanged
    });

    test('resumes from persisted progress rather than starting over', () async {
      await progressRepository.upsert(
        const ChainProgress(chainId: 'chain1', completedStageCount: 1),
      );

      final result = await service.evaluate(
        chain,
        completedQuestIds: {'q1', 'q2'},
        instant: DateTime.utc(2026, 1, 10),
      );

      expect(result.progress.completedStageCount, 2);
    });
  });
}
