import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/chains/data/models/chain_progress_hive_model.dart';
import 'package:prime/features/chains/data/repositories/hive_chain_progress_repository.dart';
import 'package:prime/features/chains/domain/entities/chain_progress.dart';

import '../../../../support/hive_test_support.dart';

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  Future<Box<ChainProgressHiveModel>> openBox() =>
      Hive.openBox<ChainProgressHiveModel>(HiveBoxNames.chainProgress);

  test('upsert then getForChain returns what was written', () async {
    final repo = HiveChainProgressRepository(await openBox());
    const progress = ChainProgress(chainId: 'chain1', completedStageCount: 1);

    await repo.upsert(progress);

    expect(await repo.getForChain('chain1'), progress);
    expect(await repo.getForChain('missing'), isNull);
  });

  test('upsert genuinely overwrites — unlike the achievements box, this is '
      'a real update, not an append-only dedup', () async {
    final repo = HiveChainProgressRepository(await openBox());
    await repo.upsert(
      const ChainProgress(chainId: 'chain1', completedStageCount: 1),
    );

    await repo.upsert(
      ChainProgress(
        chainId: 'chain1',
        completedStageCount: 3,
        completedAt: DateTime.utc(2026, 1, 10),
      ),
    );

    final stored = await repo.getForChain('chain1');
    expect(stored!.completedStageCount, 3);
    expect(stored.completedAt, DateTime.utc(2026, 1, 10));
  });

  test(
    'watchAll emits the current snapshot immediately, then again on change',
    () async {
      final repo = HiveChainProgressRepository(await openBox());
      final emissions = <int>[];
      final subscription = repo.watchAll().listen(
        (p) => emissions.add(p.length),
      );
      await pumpEventQueue();

      await repo.upsert(
        const ChainProgress(chainId: 'chain1', completedStageCount: 1),
      );
      await pumpEventQueue();

      await subscription.cancel();
      expect(emissions, [0, 1]);
    },
  );

  test(
    'survives closing and reopening the box (restart persistence)',
    () async {
      final progress = ChainProgress(
        chainId: 'chain1',
        completedStageCount: 2,
        completedAt: DateTime.utc(2026, 1, 10),
      );
      await HiveChainProgressRepository(await openBox()).upsert(progress);

      await support.reopen();

      final reopened = HiveChainProgressRepository(await openBox());
      expect(await reopened.getForChain('chain1'), progress);
    },
  );
}
