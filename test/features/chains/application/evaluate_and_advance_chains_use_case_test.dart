import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/clock.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/chains/application/services/chain_evaluation_service.dart';
import 'package:prime/features/chains/application/use_cases/evaluate_and_advance_chains_use_case.dart';
import 'package:prime/features/chains/domain/entities/chain.dart';
import 'package:prime/features/chains/domain/entities/chain_progress.dart';
import 'package:prime/features/chains/domain/repositories/chain_progress_repository.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/domain/repositories/xp_ledger_repository.dart';

class _FakeXpLedgerRepository implements XpLedgerRepository {
  final Map<String, XpTransaction> byKey = {};

  @override
  Future<void> appendAll(List<XpTransaction> transactions) async {
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

class _FakeChainProgressRepository implements ChainProgressRepository {
  final Map<String, ChainProgress> progress = {};
  int upsertCallCount = 0;
  Object? upsertError;

  @override
  Future<ChainProgress?> getForChain(String chainId) async => progress[chainId];

  @override
  Future<List<ChainProgress>> getAll() async => progress.values.toList();

  @override
  Stream<List<ChainProgress>> watchAll() =>
      Stream.value(progress.values.toList());

  @override
  Future<void> upsert(ChainProgress value) async {
    upsertCallCount++;
    if (upsertError != null) throw upsertError!;
    progress[value.chainId] = value;
  }
}

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

XpTransaction _questCompletion(String questId) {
  final sourceId = '$questId|2026-01-10|0';
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
  late _FakeChainProgressRepository progressRepository;

  EvaluateAndAdvanceChainsUseCase buildUseCase(List<Chain> catalog) {
    final service = ChainEvaluationService(
      xpLedgerRepository: ledger,
      progressRepository: progressRepository,
    );
    return EvaluateAndAdvanceChainsUseCase(
      evaluationService: service,
      progressRepository: progressRepository,
      xpLedgerRepository: ledger,
      catalog: catalog,
      clock: _FakeClock(DateTime.utc(2026, 1, 10, 9)),
    );
  }

  setUp(() {
    ledger = _FakeXpLedgerRepository();
    progressRepository = _FakeChainProgressRepository();
  });

  test(
    'completing a quest advances only chains containing that quest',
    () async {
      const chainA = Chain(
        id: 'chainA',
        title: 'A',
        description: 'd',
        iconKey: 'book',
        questIds: ['q1', 'q2'],
        sortOrder: 0,
      );
      const chainB = Chain(
        id: 'chainB',
        title: 'B',
        description: 'd',
        iconKey: 'book',
        questIds: ['q9', 'q10'],
        sortOrder: 1,
      );
      ledger.byKey['seed'] = _questCompletion('q1');
      final useCase = buildUseCase([chainA, chainB]);

      await useCase.execute();

      expect(
        (await progressRepository.getForChain('chainA'))!.completedStageCount,
        1,
      );
      expect(
        await progressRepository.getForChain('chainB'),
        isNull,
      ); // untouched
    },
  );

  test('completing an unrelated quest changes nothing', () async {
    const chain = Chain(
      id: 'chainA',
      title: 'A',
      description: 'd',
      iconKey: 'book',
      questIds: ['q1', 'q2'],
      sortOrder: 0,
    );
    ledger.byKey['seed'] = _questCompletion('unrelated-quest');
    final useCase = buildUseCase([chain]);

    final result = await useCase.execute();

    expect((result as Ok<List<Chain>>).value, isEmpty);
    expect(await progressRepository.getForChain('chainA'), isNull);
    expect(progressRepository.upsertCallCount, 0);
  });

  test('completing the last stage awards the reward exactly once', () async {
    const chain = Chain(
      id: 'chainA',
      title: 'A',
      description: 'd',
      iconKey: 'book',
      questIds: ['q1'],
      rewardXp: 50,
      sortOrder: 0,
    );
    ledger.byKey['seed'] = _questCompletion('q1');
    final useCase = buildUseCase([chain]);

    final first = await useCase.execute();
    expect((first as Ok<List<Chain>>).value.map((c) => c.id), ['chainA']);
    expect(await ledger.sumLifetimeXp(), 150); // 100 quest + 50 chain reward

    final second = await useCase.execute();
    expect((second as Ok<List<Chain>>).value, isEmpty); // already completed
    expect(
      await ledger.sumLifetimeXp(),
      150,
    ); // unchanged — no duplicate reward

    final rewardRows = ledger.byKey.values.where(
      (t) => t.sourceType == XpSourceType.chainMilestone,
    );
    expect(rewardRows.length, 1);
  });

  test('one quest may belong to multiple chains safely', () async {
    const chainA = Chain(
      id: 'chainA',
      title: 'A',
      description: 'd',
      iconKey: 'book',
      questIds: ['shared'],
      rewardXp: 10,
      sortOrder: 0,
    );
    const chainB = Chain(
      id: 'chainB',
      title: 'B',
      description: 'd',
      iconKey: 'book',
      questIds: ['shared'],
      rewardXp: 20,
      sortOrder: 1,
    );
    ledger.byKey['seed'] = _questCompletion('shared');
    final useCase = buildUseCase([chainA, chainB]);

    final result = await useCase.execute();

    final completed = (result as Ok<List<Chain>>).value
        .map((c) => c.id)
        .toSet();
    expect(completed, {'chainA', 'chainB'});
    expect(await ledger.sumLifetimeXp(), 130); // 100 quest + 10 + 20 rewards
    expect(
      (await progressRepository.getForChain('chainA'))!.completedAt,
      isNotNull,
    );
    expect(
      (await progressRepository.getForChain('chainB'))!.completedAt,
      isNotNull,
    );
  });

  test('ledger write happens before the progress write — a failure persisting '
      'progress leaves the reward already granted, and a retry completes '
      'without granting it again', () async {
    const chain = Chain(
      id: 'chainA',
      title: 'A',
      description: 'd',
      iconKey: 'book',
      questIds: ['q1'],
      rewardXp: 50,
      sortOrder: 0,
    );
    ledger.byKey['seed'] = _questCompletion('q1');
    progressRepository.upsertError = Exception('disk full');
    final useCase = buildUseCase([chain]);

    final failed = await useCase.execute();
    expect(failed, isA<Err<List<Chain>>>());
    expect(await ledger.sumLifetimeXp(), 150); // reward already written
    expect(await progressRepository.getForChain('chainA'), isNull);

    progressRepository.upsertError = null;
    final retried = await useCase.execute();

    expect((retried as Ok<List<Chain>>).value.map((c) => c.id), ['chainA']);
    expect(await ledger.sumLifetimeXp(), 150); // never granted twice
    expect(
      (await progressRepository.getForChain('chainA'))!.completedAt,
      isNotNull,
    );
  });

  test('a chain with no reward completes without writing any XP', () async {
    const chain = Chain(
      id: 'chainA',
      title: 'A',
      description: 'd',
      iconKey: 'book',
      questIds: ['q1'],
      sortOrder: 0, // rewardXp defaults to 0
    );
    ledger.byKey['seed'] = _questCompletion('q1');
    final useCase = buildUseCase([chain]);

    await useCase.execute();

    expect(await ledger.sumLifetimeXp(), 100); // just the quest's own XP
  });

  test(
    'no eligible chains returns an empty list without writing anything',
    () async {
      const chain = Chain(
        id: 'chainA',
        title: 'A',
        description: 'd',
        iconKey: 'book',
        questIds: ['q1'],
        sortOrder: 0,
      );
      final useCase = buildUseCase([chain]);

      final result = await useCase.execute();

      expect((result as Ok<List<Chain>>).value, isEmpty);
      expect(progressRepository.upsertCallCount, 0);
    },
  );
}
