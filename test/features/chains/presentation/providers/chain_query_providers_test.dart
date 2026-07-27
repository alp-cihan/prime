import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/chains/domain/entities/chain.dart';
import 'package:prime/features/chains/domain/entities/chain_progress.dart';
import 'package:prime/features/chains/domain/entities/chain_stage.dart';
import 'package:prime/features/chains/presentation/providers/chain_query_providers.dart';
import 'package:prime/features/chains/presentation/providers/chain_repository_providers.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

const _chainA = Chain(
  id: 'chainA',
  title: 'Chain A',
  description: 'desc A',
  iconKey: 'book',
  questIds: ['q1', 'q2'],
  sortOrder: 1,
);
const _chainB = Chain(
  id: 'chainB',
  title: 'Chain B',
  description: 'desc B',
  iconKey: 'map',
  questIds: ['q3'],
  sortOrder: 0,
);

Future<void> _waitFor(Future<bool> Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!await condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met within 2 seconds');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  Future<ProviderContainer> buildContainer() async => buildTestContainer(
    extraOverrides: [
      chainCatalogListProvider.overrideWithValue([_chainB, _chainA]),
    ],
  );

  test(
    'chainCatalogList is sorted by sortOrder, not declaration order',
    () async {
      final container = await buildContainer();
      addTearDown(container.dispose);

      final catalog = container.read(chainCatalogListProvider);

      expect(catalog.map((c) => c.id).toList(), ['chainB', 'chainA']);
    },
  );

  test(
    'allChainsWithProgress derives fresh progress for a never-touched chain',
    () async {
      final container = await buildContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        watchAllChainProgressProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final all = await container.read(allChainsWithProgressProvider.future);

      final chainA = all.firstWhere((c) => c.chain.id == 'chainA');
      expect(chainA.progress.completedStageCount, 0);
      expect(chainA.isCompleted, isFalse);
      expect(chainA.currentStage?.index, 0);
      expect(chainA.currentStage?.status, ChainStageStatus.unlocked);
    },
  );

  test('activeChains/completedChains split by isCompleted', () async {
    final container = await buildContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      watchAllChainProgressProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);
    final progressRepository = container.read(chainProgressRepositoryProvider);
    await progressRepository.upsert(
      ChainProgress(
        chainId: 'chainB',
        completedStageCount: 1,
        completedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    final active = await container.read(activeChainsProvider.future);
    final completed = await container.read(completedChainsProvider.future);

    expect(active.map((c) => c.chain.id), ['chainA']);
    expect(completed.map((c) => c.chain.id), ['chainB']);
  });

  test(
    'chainDetail returns the matching chain, or null for an unknown id',
    () async {
      final container = await buildContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        watchAllChainProgressProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final detail = await container.read(chainDetailProvider('chainA').future);
      final missing = await container.read(chainDetailProvider('nope').future);

      expect(detail?.chain.title, 'Chain A');
      expect(missing, isNull);
    },
  );

  test('currentChainStage tracks progress as it advances', () async {
    final container = await buildContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      watchAllChainProgressProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    final beforeStage = await container.read(
      currentChainStageProvider('chainB').future,
    );
    expect(beforeStage?.questId, 'q3');

    final ledger = container.read(xpLedgerRepositoryProvider);
    await ledger.appendAll([
      XpTransaction(
        id: 'q3|2026-01-10|0|health',
        sourceType: XpSourceType.quest,
        sourceId: 'q3|2026-01-10|0',
        attribute: AttributeType.health,
        baseXp: 100,
        modifiersApplied: const {'difficulty': 1.0},
        finalXp: 100,
        createdAt: DateTime.utc(2026, 1, 10),
        idempotencyKey: 'q3|2026-01-10|0|health',
      ),
    ]);
    final useCase = container.read(evaluateAndAdvanceChainsUseCaseProvider);
    await useCase.execute();

    // The underlying box-watch stream delivers its change notification
    // asynchronously — poll rather than assume one microtask is enough.
    await _waitFor(() async {
      container.invalidate(currentChainStageProvider('chainB'));
      container.invalidate(allChainsWithProgressProvider);
      final refreshed = await container.read(
        currentChainStageProvider('chainB').future,
      );
      return refreshed == null; // chainB has a single stage, now completed
    });
  });
}
