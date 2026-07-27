import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/chains/domain/entities/chain.dart';
import 'package:prime/features/chains/domain/entities/chain_progress.dart';
import 'package:prime/features/chains/presentation/chain_detail_page.dart';
import 'package:prime/features/chains/presentation/providers/chain_repository_providers.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';

const _chain = Chain(
  id: 'chainA',
  title: 'The Long Road',
  description: 'A chain of quests.',
  iconKey: 'book',
  questIds: ['q1', 'q2', 'q3'],
  sortOrder: 0,
);

Quest _quest(String id, String title) {
  return Quest(
    id: id,
    title: title,
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 60},
    linkedIdentityStatementIds: const [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: const [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
  );
}

void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _harness(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: ChainDetailPage(chainId: 'chainA')),
  );
}

void main() {
  testWidgets('shows every stage with its quest title and status', (
    tester,
  ) async {
    _growViewport(tester);
    final questRepository = FakeQuestRepository()
      ..quests['q1'] = _quest('q1', 'First Quest')
      ..quests['q2'] = _quest('q2', 'Second Quest')
      ..quests['q3'] = _quest('q3', 'Third Quest');
    final progressRepository = FakeChainProgressRepository();
    await progressRepository.upsert(
      const ChainProgress(chainId: 'chainA', completedStageCount: 1),
    );

    await tester.pumpWidget(
      _harness([
        chainCatalogListProvider.overrideWithValue([_chain]),
        chainProgressRepositoryProvider.overrideWithValue(progressRepository),
        questRepositoryProvider.overrideWithValue(questRepository),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('The Long Road'), findsWidgets); // AppBar title + body
    expect(find.text('First Quest'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Second Quest'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    // The third stage is locked — its quest title must not leak through.
    expect(find.text('Third Quest'), findsNothing);
    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Complete the current stage first'), findsOneWidget);
  });

  testWidgets('shows 100% and no locked stages once the chain is completed', (
    tester,
  ) async {
    _growViewport(tester);
    final questRepository = FakeQuestRepository()
      ..quests['q1'] = _quest('q1', 'First Quest')
      ..quests['q2'] = _quest('q2', 'Second Quest')
      ..quests['q3'] = _quest('q3', 'Third Quest');
    final progressRepository = FakeChainProgressRepository();
    await progressRepository.upsert(
      ChainProgress(
        chainId: 'chainA',
        completedStageCount: 3,
        completedAt: DateTime.utc(2026, 1, 10),
      ),
    );

    await tester.pumpWidget(
      _harness([
        chainCatalogListProvider.overrideWithValue([_chain]),
        chainProgressRepositoryProvider.overrideWithValue(progressRepository),
        questRepositoryProvider.overrideWithValue(questRepository),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('100% complete'), findsOneWidget);
    expect(find.textContaining('chain finished'), findsOneWidget);
    expect(find.text('Locked'), findsNothing);
    expect(find.text('Third Quest'), findsOneWidget);
  });

  testWidgets('shows a not-found state for an unknown chain id', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness([
        chainCatalogListProvider.overrideWithValue(const []),
        chainProgressRepositoryProvider.overrideWithValue(
          FakeChainProgressRepository(),
        ),
        questRepositoryProvider.overrideWithValue(FakeQuestRepository()),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining("doesn't exist"), findsOneWidget);
  });
}
