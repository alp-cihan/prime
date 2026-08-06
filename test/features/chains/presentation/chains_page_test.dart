import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/features/chains/domain/entities/chain.dart';
import 'package:prime/features/chains/domain/entities/chain_progress.dart';
import 'package:prime/core/router/app_routes.dart';
import 'package:prime/features/chains/presentation/chain_detail_page.dart';
import 'package:prime/features/chains/presentation/chains_page.dart';
import 'package:prime/features/chains/presentation/providers/chain_repository_providers.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/test_localizations.dart';

const _visibleChain = Chain(
  id: 'chainA',
  title: 'The Long Road',
  description: 'A visible chain.',
  iconKey: 'book',
  questIds: ['q1', 'q2'],
  sortOrder: 0,
);
const _hiddenChain = Chain(
  id: 'chainB',
  title: 'Secret Chain',
  description: 'A hidden chain.',
  iconKey: 'map',
  questIds: ['q3'],
  hiddenUntilStarted: true,
  sortOrder: 1,
);

void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _harness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: AppRoutes.chains,
    routes: [
      GoRoute(
        path: AppRoutes.chains,
        builder: (context, state) => const ChainsPage(),
        routes: [
          GoRoute(
            path: AppRoutes.chainDetailSegment,
            builder: (context, state) =>
                ChainDetailPage(chainId: state.pathParameters['chainId']!),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
    ),
  );
}

void main() {
  testWidgets('shows an empty state when no chains exist', (tester) async {
    _growViewport(tester);
    await tester.pumpWidget(
      _harness([
        chainCatalogListProvider.overrideWithValue(const []),
        chainProgressRepositoryProvider.overrideWithValue(
          FakeChainProgressRepository(),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('No active chains yet.'), findsOneWidget);
    expect(find.text('No chains completed yet.'), findsOneWidget);
  });

  testWidgets(
    'shows a not-yet-started chain in Active with title/description/progress',
    (tester) async {
      _growViewport(tester);
      await tester.pumpWidget(
        _harness([
          chainCatalogListProvider.overrideWithValue([_visibleChain]),
          chainProgressRepositoryProvider.overrideWithValue(
            FakeChainProgressRepository(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('The Long Road'), findsOneWidget);
      expect(find.text('A visible chain.'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('No chains completed yet.'), findsOneWidget);
    },
  );

  testWidgets('a hidden, not-yet-started chain shows only "Hidden Chain"', (
    tester,
  ) async {
    _growViewport(tester);
    await tester.pumpWidget(
      _harness([
        chainCatalogListProvider.overrideWithValue([_hiddenChain]),
        chainProgressRepositoryProvider.overrideWithValue(
          FakeChainProgressRepository(),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hidden Chain'), findsOneWidget);
    expect(find.text('Secret Chain'), findsNothing);
    expect(find.text('A hidden chain.'), findsNothing);
  });

  testWidgets('a completed chain appears in the Completed section', (
    tester,
  ) async {
    _growViewport(tester);
    final repository = FakeChainProgressRepository();
    await repository.upsert(
      ChainProgress(
        chainId: 'chainA',
        completedStageCount: 2,
        completedAt: DateTime.utc(2026, 1, 10),
      ),
    );
    await tester.pumpWidget(
      _harness([
        chainCatalogListProvider.overrideWithValue([_visibleChain]),
        chainProgressRepositoryProvider.overrideWithValue(repository),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('No active chains yet.'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('tapping a chain card navigates to its detail page', (
    tester,
  ) async {
    _growViewport(tester);
    await tester.pumpWidget(
      _harness([
        chainCatalogListProvider.overrideWithValue([_visibleChain]),
        chainProgressRepositoryProvider.overrideWithValue(
          FakeChainProgressRepository(),
        ),
        questRepositoryProvider.overrideWithValue(FakeQuestRepository()),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('The Long Road'));
    await tester.pumpAndSettle();

    expect(find.text('Stages'), findsOneWidget); // Chain Detail page content
  });
}
