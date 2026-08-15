import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/today/presentation/today_page.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/presentation/providers/player_level_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/test_localizations.dart';
import '../../../support/widget_test_harness.dart';

final _today = DateTime.utc(2026, 1, 10);

Quest _buildQuest({
  required String id,
  required String title,
  QuestCompletionState state = QuestCompletionState.notStarted,
  String? visualKey,
  ProgressType progressType = ProgressType.binary,
  double targetProgress = 1,
}) {
  return Quest(
    id: id,
    title: title,
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 60},
    linkedIdentityStatementIds: const [],
    progressType: progressType,
    currentProgress: 0,
    targetProgress: targetProgress,
    prerequisiteQuestIds: const [],
    state: state,
    failureBehavior: FailureBehavior.expire,
    visualKey: visualKey,
  );
}

XpTransaction _xpTx(AttributeType attribute, int finalXp) {
  final sourceId = '${attribute.name}|2026-01-10|0';
  return XpTransaction(
    id: sourceId,
    sourceType: XpSourceType.manualAdjustment,
    sourceId: sourceId,
    attribute: attribute,
    baseXp: finalXp,
    modifiersApplied: const {},
    finalXp: finalXp,
    createdAt: _today,
    idempotencyKey: sourceId,
  );
}

Widget _harness(List<Override> overrides, {Locale? locale}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const TodayPage()),
      // Declared before `/quests/:questId` so `/quests/new` resolves here —
      // same sibling-route ordering the real app_router.dart relies on.
      GoRoute(
        path: '/quests/new',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('quest-new-page'))),
      ),
      GoRoute(
        path: '/quests/:questId',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Text('detail:${state.pathParameters['questId']}'),
          ),
        ),
      ),
      GoRoute(
        path: '/suggestions',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('suggestions-page'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
    ),
  );
}

/// The dashboard has more content than the default test surface (800x600),
/// and `ListView` virtualizes children outside the viewport — without this,
/// sections below the fold (e.g. Growth Today) are never mounted, so
/// `find.text` cannot locate them no matter how long `pumpAndSettle` runs.
void _growViewport(
  WidgetTester tester, {
  double width = 800,
  double height = 3000,
}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('shows loading indicators before providers resolve', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness(overrides));

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('renders a coherent empty state with no quests and no XP', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    // The Phase 16 "Browse Suggestions" button on the empty featured-quest
    // card adds enough height to push "No XP earned today" (Growth Today,
    // near the bottom) outside the default 800x600 surface, where
    // `ListView`'s sliver virtualization never builds it — same fix as the
    // other tests below that already call `_growViewport`.
    _growViewport(tester);
    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.textContaining('0 XP total'), findsOneWidget);
    expect(
      find.textContaining(
        'No quests yet. Quests you create will show up here.',
      ),
      findsWidgets, // both the featured quest card and the quest list show this
    );
    expect(find.text('No quests yet'), findsOneWidget); // Daily momentum card
    expect(find.text('No XP earned today'), findsOneWidget); // Growth today
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    "the empty state's Browse Suggestions button reaches /suggestions",
    (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Browse Suggestions'),
      );
      await tester.pumpAndSettle();

      expect(find.text('suggestions-page'), findsOneWidget);
    },
  );

  testWidgets(
    'renders player level, featured quest, daily momentum, and quest list',
    (tester) async {
      _growViewport(tester);
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout')
        ..quests['q2'] = _buildQuest(id: 'q2', title: 'Read');
      final progressRepository = FakeQuestProgressRepository()
        ..entries.add(
          QuestProgress(
            questId: 'q1',
            date: _today,
            progressValue: 1,
            isComplete: true,
          ),
        );
      final ledgerRepository = FakeXpLedgerRepository()
        ..byKey['q1|health|2026-01-10|0'] = XpTransaction(
          id: 'x1',
          sourceType: XpSourceType.quest,
          sourceId: 'q1|2026-01-10|0',
          attribute: AttributeType.health,
          baseXp: 60,
          modifiersApplied: const {},
          finalXp: 75,
          createdAt: _today,
          idempotencyKey: 'q1|health|2026-01-10|0',
        );
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: progressRepository,
        xpLedgerRepository: ledgerRepository,
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      // Player header: 75 total XP, still Level 1.
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.textContaining('75 XP total'), findsOneWidget);

      // Daily momentum: 1 of 2 quests completed today, plus today's XP.
      expect(find.textContaining('1 of 2 quests completed'), findsOneWidget);
      expect(find.text('75 XP today'), findsOneWidget);

      // Featured quest: q1 already complete today, so q2 ("Read") is featured
      // — it renders both in the featured card and the Daily Quest List.
      expect(find.text('Read'), findsWidgets);

      // The quest list shows both quests, one marked complete.
      expect(find.text('Workout'), findsWidgets);
      expect(find.text('Completed today'), findsOneWidget);

      // Growth today: a single attribute tile for Health.
      expect(find.text('Growth today'), findsOneWidget);
      expect(find.text('75 XP'), findsOneWidget); // attribute tile only now
      expect(find.text('Health'), findsWidgets); // quest chips + attribute tile

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Phase 17.2: the Featured Quest card renders the quest visualKey\'s '
    'bundled asset, not the gradient placeholder',
    (tester) async {
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest(
          id: 'q1',
          title: 'Walk',
          visualKey: 'fitness/walk_20',
        );
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        'assets/visuals/walking.png',
      );
    },
  );

  testWidgets(
    'Growth today shows at most 3 attributes, sorted highest XP first',
    (tester) async {
      _growViewport(tester);
      final ledgerRepository = FakeXpLedgerRepository()
        ..byKey['health'] = _xpTx(AttributeType.health, 100)
        ..byKey['strength'] = _xpTx(AttributeType.strength, 90)
        ..byKey['discipline'] = _xpTx(AttributeType.discipline, 80)
        ..byKey['knowledge'] = _xpTx(AttributeType.knowledge, 70);
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: ledgerRepository,
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(find.text('Health'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Discipline'), findsOneWidget);
      expect(find.text('Knowledge'), findsNothing);

      expect(find.text('100 XP'), findsOneWidget);
      expect(find.text('90 XP'), findsOneWidget);
      expect(find.text('80 XP'), findsOneWidget);
      expect(find.text('70 XP'), findsNothing);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tapping the featured quest navigates to its detail route', (
    tester,
  ) async {
    final questRepository = FakeQuestRepository()
      ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout');
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Workout').first);
    await tester.pumpAndSettle();

    expect(find.text('detail:q1'), findsOneWidget);
  });

  testWidgets(
    'a section provider failure shows a friendly message, not a crash',
    (tester) async {
      final overrides = [
        ...fakeProviderOverrides(
          questRepository: FakeQuestRepository(),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        ),
        playerLevelSummaryProvider.overrideWith(
          (ref) => Future.error(Exception('ledger unavailable')),
        ),
      ];

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(find.textContaining("Couldn't load your level"), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a very long quest title renders without overflow on a narrow phone '
    'viewport',
    (tester) async {
      _growViewport(tester, width: 360, height: 690);

      final longTitle =
          'Read a full chapter of a very long book about distributed '
          'systems every single morning before work';
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest(id: 'q1', title: longTitle);
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the full dashboard renders without overflow on a narrow phone viewport '
    'with a large lifetime XP total',
    (tester) async {
      _growViewport(tester, width: 360, height: 1400);

      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout')
        ..quests['q2'] = _buildQuest(id: 'q2', title: 'Read');
      final ledgerRepository = FakeXpLedgerRepository()
        ..byKey['health'] = _xpTx(AttributeType.health, 1234567)
        ..byKey['strength'] = _xpTx(AttributeType.strength, 890)
        ..byKey['discipline'] = _xpTx(AttributeType.discipline, 12);
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: ledgerRepository,
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  group('Phase 18 (Today 2.0)', () {
    testWidgets(
      'hero fallback: a hand-typed quest with no visualKey renders the '
      'gradient placeholder, not an Image',
      (tester) async {
        final questRepository = FakeQuestRepository()
          ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout');
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness(overrides));
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets("the empty state's Create Quest button reaches /quests/new", (
      tester,
    ) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pumpAndSettle();

      expect(find.text('quest-new-page'), findsOneWidget);
    });

    testWidgets(
      'a completed featured quest shows the completed chip and a View CTA',
      (tester) async {
        final questRepository = FakeQuestRepository()
          ..quests['q1'] = _buildQuest(
            id: 'q1',
            title: 'Workout',
            state: QuestCompletionState.complete,
          );
        final progressRepository = FakeQuestProgressRepository()
          ..entries.add(
            QuestProgress(
              questId: 'q1',
              date: _today,
              progressValue: 1,
              isComplete: true,
            ),
          );
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: progressRepository,
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness(overrides));
        await tester.pumpAndSettle();

        expect(find.text('Completed today'), findsWidgets);
        expect(find.text('View'), findsOneWidget);
        expect(find.text('Begin'), findsNothing);
      },
    );

    group('Continue section visibility', () {
      testWidgets('omitted entirely when there is only the featured quest', (
        tester,
      ) async {
        final questRepository = FakeQuestRepository()
          ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout');
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness(overrides));
        await tester.pumpAndSettle();

        expect(find.text('CONTINUE'), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'omitted when the second quest is binary (no measurable progress)',
        (tester) async {
          final questRepository = FakeQuestRepository()
            ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout')
            ..quests['q2'] = _buildQuest(id: 'q2', title: 'Read');
          final overrides = fakeProviderOverrides(
            questRepository: questRepository,
            questProgressRepository: FakeQuestProgressRepository(),
            xpLedgerRepository: FakeXpLedgerRepository(),
            today: _today,
          );

          await tester.pumpWidget(_harness(overrides));
          await tester.pumpAndSettle();

          expect(find.text('CONTINUE'), findsNothing);
        },
      );

      testWidgets('omitted when the second quest has zero progress today', (
        tester,
      ) async {
        final questRepository = FakeQuestRepository()
          ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout')
          ..quests['q2'] = _buildQuest(
            id: 'q2',
            title: 'Read 20 pages',
            progressType: ProgressType.quantity,
            targetProgress: 20,
          );
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness(overrides));
        await tester.pumpAndSettle();

        expect(find.text('CONTINUE'), findsNothing);
      });

      testWidgets(
        'shown for a second, non-featured quest with measurable progress > 0',
        (tester) async {
          _growViewport(tester);
          final questRepository = FakeQuestRepository()
            ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout')
            ..quests['q2'] = _buildQuest(
              id: 'q2',
              title: 'Read 20 pages',
              progressType: ProgressType.quantity,
              targetProgress: 20,
            );
          final progressRepository = FakeQuestProgressRepository()
            ..entries.add(
              QuestProgress(
                questId: 'q2',
                date: _today,
                progressValue: 12,
                isComplete: false,
              ),
            );
          final overrides = fakeProviderOverrides(
            questRepository: questRepository,
            questProgressRepository: progressRepository,
            xpLedgerRepository: FakeXpLedgerRepository(),
            today: _today,
          );

          await tester.pumpWidget(_harness(overrides));
          await tester.pumpAndSettle();

          expect(find.text('CONTINUE'), findsOneWidget);
          expect(find.text('Read 20 pages'), findsWidgets);
          // Once on the Continue card, once more on the same quest's row in
          // the full Today's Quests list below it — both legitimately show
          // live progress for the same quest.
          expect(find.text('12 / 20'), findsWidgets);
        },
      );

      testWidgets(
        'tapping the Continue card navigates to that quest\'s detail route',
        (tester) async {
          _growViewport(tester);
          final questRepository = FakeQuestRepository()
            ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout')
            ..quests['q2'] = _buildQuest(
              id: 'q2',
              title: 'Read 20 pages',
              progressType: ProgressType.quantity,
              targetProgress: 20,
            );
          final progressRepository = FakeQuestProgressRepository()
            ..entries.add(
              QuestProgress(
                questId: 'q2',
                date: _today,
                progressValue: 12,
                isComplete: false,
              ),
            );
          final overrides = fakeProviderOverrides(
            questRepository: questRepository,
            questProgressRepository: progressRepository,
            xpLedgerRepository: FakeXpLedgerRepository(),
            today: _today,
          );

          await tester.pumpWidget(_harness(overrides));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Read 20 pages').last);
          await tester.pumpAndSettle();

          expect(find.text('detail:q2'), findsOneWidget);
        },
      );
    });

    testWidgets(
      'tapping a non-featured quest in Today\'s Quests navigates to its '
      'own detail route',
      (tester) async {
        _growViewport(tester);
        final questRepository = FakeQuestRepository()
          ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout')
          ..quests['q2'] = _buildQuest(
            id: 'q2',
            title: 'Read',
            state: QuestCompletionState.complete,
          );
        final progressRepository = FakeQuestProgressRepository()
          ..entries.add(
            QuestProgress(
              questId: 'q2',
              date: _today,
              progressValue: 1,
              isComplete: true,
            ),
          );
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: progressRepository,
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness(overrides));
        await tester.pumpAndSettle();

        // q1 is featured (q2 is already complete today); tap q2 in the
        // Today's Quests list specifically, not the hero.
        await tester.tap(find.text('Read').last);
        await tester.pumpAndSettle();

        expect(find.text('detail:q2'), findsOneWidget);
      },
    );

    testWidgets(
      'renders in Turkish: hero eyebrow, Begin CTA, and nav title all '
      'localize',
      (tester) async {
        final questRepository = FakeQuestRepository()
          ..quests['q1'] = _buildQuest(id: 'q1', title: 'Egzersiz yap');
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(
          _harness(overrides, locale: const Locale('tr')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Bugün'), findsWidgets); // nav title + AppBar
        expect(find.text('BUGÜNÜN GÖREVİ'), findsOneWidget);
        expect(find.text('Başla'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('renders in English: hero eyebrow and Begin CTA are English', (
      tester,
    ) async {
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout');
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides, locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text("TODAY'S MISSION"), findsOneWidget);
      expect(find.text('Begin'), findsOneWidget);
    });

    testWidgets(
      'a long Turkish quest title renders without overflow at 360px width',
      (tester) async {
        _growViewport(tester, width: 360, height: 900);

        const longTurkishTitle =
            'Dağıtık sistemler hakkında çok uzun bir kitabın tam bir '
            'bölümünü her sabah işe gitmeden önce oku';
        final questRepository = FakeQuestRepository()
          ..quests['q1'] = _buildQuest(id: 'q1', title: longTurkishTitle);
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(
          _harness(overrides, locale: const Locale('tr')),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '360px width with every section present (hero, Continue, completed '
      'quest, Growth Today) renders without overflow',
      (tester) async {
        _growViewport(tester, width: 360, height: 1600);

        final questRepository = FakeQuestRepository()
          ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout')
          ..quests['q2'] = _buildQuest(
            id: 'q2',
            title: 'Read 20 pages of a long book about distributed systems',
            progressType: ProgressType.quantity,
            targetProgress: 20,
          )
          ..quests['q3'] = _buildQuest(
            id: 'q3',
            title: 'Meditate',
            state: QuestCompletionState.complete,
          );
        final progressRepository = FakeQuestProgressRepository()
          ..entries.addAll([
            QuestProgress(
              questId: 'q2',
              date: _today,
              progressValue: 12,
              isComplete: false,
            ),
            QuestProgress(
              questId: 'q3',
              date: _today,
              progressValue: 1,
              isComplete: true,
            ),
          ]);
        final ledgerRepository = FakeXpLedgerRepository()
          ..byKey['health'] = _xpTx(AttributeType.health, 100)
          ..byKey['strength'] = _xpTx(AttributeType.strength, 90)
          ..byKey['discipline'] = _xpTx(AttributeType.discipline, 80);
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: progressRepository,
          xpLedgerRepository: ledgerRepository,
          today: _today,
        );

        await tester.pumpWidget(
          _harness(overrides, locale: const Locale('tr')),
        );
        await tester.pumpAndSettle();

        expect(find.text('DEVAM ET'), findsOneWidget); // Continue, in Turkish
        expect(tester.takeException(), isNull);
      },
    );
  });
}
