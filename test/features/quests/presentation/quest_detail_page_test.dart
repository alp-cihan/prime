import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/presentation/quest_detail_page.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/test_localizations.dart';
import '../../../support/widget_test_harness.dart';

final _today = DateTime.utc(2026, 1, 10);

Quest _buildQuest({
  String id = 'q1',
  String title = 'Workout',
  String description = 'Go to the gym',
  QuestCompletionState state = QuestCompletionState.notStarted,
  String? visualKey,
  ProgressType progressType = ProgressType.binary,
  double targetProgress = 1,
}) {
  return Quest(
    id: id,
    title: title,
    description: description,
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {
      AttributeType.health: 60,
      AttributeType.strength: 40,
    },
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

/// Same reasoning as `today_page_test.dart`/`quest_progress_controls_widget_test.dart`'s
/// identically-named helper — the Phase 19 hero + Rewards + Why-this-matters
/// sections push content well past the default 800x600 test surface.
void _growViewport(
  WidgetTester tester, {
  double width = 800,
  double height = 1400,
}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _harness(String questId, List<Override> overrides, {Locale? locale}) {
  final router = GoRouter(
    initialLocation: '/quests/$questId',
    routes: [
      GoRoute(
        path: '/quests',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('quest-list'))),
        routes: [
          GoRoute(
            path: ':questId',
            builder: (context, state) =>
                QuestDetailPage(questId: state.pathParameters['questId']!),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => Scaffold(
                  body: Center(
                    child: Text('edit-form:${state.pathParameters['questId']}'),
                  ),
                ),
              ),
            ],
          ),
        ],
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

void main() {
  testWidgets('shows a loading indicator before questByIdProvider resolves', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a not-found state for a missing quest id', (tester) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('missing', overrides));
    await tester.pumpAndSettle();

    expect(find.textContaining("doesn't exist"), findsOneWidget);
  });

  testWidgets('renders quest data: title, description, difficulty, base XP', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    // AppBar title + the hero's own overlaid title (Phase 19).
    expect(find.text('Workout'), findsWidgets);
    expect(find.text('Go to the gym'), findsOneWidget);
    // Difficulty is shown both on the hero footer and in the Rewards
    // section (Phase 19) — both bullet lists in the spec ask for it.
    expect(find.text('Normal'), findsWidgets);
    expect(find.textContaining('100 XP'), findsWidgets); // 60 + 40
  });

  testWidgets("renders today's progress", (tester) async {
    // A real completion always writes progress + ledger rows together
    // (CompleteQuestUseCase), so a realistic fixture seeds both.
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
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: progressRepository,
      xpLedgerRepository: ledgerRepository,
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    expect(find.text('1 time'), findsOneWidget);
  });

  testWidgets("renders today's XP earned for this quest", (tester) async {
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
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: ledgerRepository,
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    expect(find.text('75 XP'), findsOneWidget);
  });

  testWidgets(
    'tapping Complete triggers the controller and disables the button while loading',
    (tester) async {
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness('q1', overrides));
      await tester
          .pumpAndSettle(); // initial load already resolved questByIdProvider's own getById call

      // Gate CompleteQuestUseCase's first repository call so the completion
      // pipeline provably suspends mid-flight, instead of racing a fake that
      // would otherwise resolve within the same microtask flush as pump().
      final gate = Completer<void>();
      questRepository.getByIdGate = gate;

      await tester.tap(find.text('Complete Quest'));
      await tester
          .pump(); // one frame: loading state, use case suspended on the gate

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull); // disabled while loading
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      gate.complete();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('success shows a confirmation with the awarded XP', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Quest'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('+125 XP'),
      findsOneWidget,
    ); // round(100) * 1.25 first-completion bonus
  });

  testWidgets(
    "provider-backed progress and XP update after success, without manual refresh",
    (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness('q1', overrides));
      await tester.pumpAndSettle();

      expect(find.text('Not yet'), findsOneWidget);

      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();

      expect(find.text('Not yet'), findsNothing);
      expect(find.text('1 time'), findsOneWidget);
      expect(find.text('125 XP'), findsOneWidget);
    },
  );

  testWidgets(
    'a completion failure displays a readable error and allows retry',
    (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = _buildQuest(state: QuestCompletionState.expired),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness('q1', overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't complete this quest"), findsOneWidget);
      expect(find.textContaining('cannot be completed'), findsOneWidget);

      // Retry stays available and re-attempts through the same controller.
      final retryButton = find.widgetWithText(OutlinedButton, 'Retry');
      expect(retryButton, findsOneWidget);
      await tester.ensureVisible(
        retryButton,
      ); // may be below the fold in the SingleChildScrollView
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(find.text("Couldn't complete this quest"), findsOneWidget);
    },
  );

  testWidgets('the edit action navigates to the edit route', (tester) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('edit-form:q1'), findsOneWidget);
  });

  testWidgets('the delete action opens a confirmation naming the quest', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete quest?'), findsOneWidget);
    expect(find.textContaining('"Workout"'), findsOneWidget);
  });

  testWidgets('cancel leaves the quest untouched', (tester) async {
    final questRepository = FakeQuestRepository()..quests['q1'] = _buildQuest();
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete quest?'), findsNothing);
    expect(questRepository.quests.containsKey('q1'), isTrue);
    expect(find.text('quest-list'), findsNothing); // did not navigate away
  });

  testWidgets('confirm deletes the quest and returns to the quest list', (
    tester,
  ) async {
    final questRepository = FakeQuestRepository()..quests['q1'] = _buildQuest();
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(questRepository.quests.containsKey('q1'), isFalse);
    expect(find.text('quest-list'), findsOneWidget);
  });

  testWidgets(
    'delete loading disables the delete action, preventing a duplicate dialog',
    (tester) async {
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest();
      final progressRepository = FakeQuestProgressRepository();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: progressRepository,
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness('q1', overrides));
      await tester.pumpAndSettle();

      final gate = Completer<void>();
      progressRepository.deleteAllForQuestGate = gate;

      await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      // Bounded pumps, not pumpAndSettle: the AppBar's own
      // CircularProgressIndicator (shown while deletion is in flight) is
      // indeterminate and animates forever, which would make pumpAndSettle
      // time out. These still give the dialog's close transition time to
      // finish.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // The delete icon is replaced by a spinner and disabled — attempting
      // to tap it again cannot reopen the confirmation dialog while this
      // deletion is still in flight.
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      await tester.tap(find.byTooltip('Delete Quest'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Delete quest?'), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();
      expect(questRepository.quests.containsKey('q1'), isFalse);
    },
  );

  testWidgets(
    'a delete failure keeps the user on the detail screen and shows an error',
    (tester) async {
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest();
      final progressRepository = FakeQuestProgressRepository()
        ..deleteAllForQuestError = Exception('box error');
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: progressRepository,
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness('q1', overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      // Stayed on the detail screen — never navigated to the list.
      expect(find.text('quest-list'), findsNothing);
      // AppBar title + the hero's own overlaid title (Phase 19).
      expect(find.text('Workout'), findsWidgets);
      expect(questRepository.quests.containsKey('q1'), isTrue);
    },
  );

  group('Phase 19 (Quest Detail redesign)', () {
    testWidgets(
      'hero renders the quest visualKey\'s bundled asset, not the gradient '
      'placeholder',
      (tester) async {
        final overrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository()
            ..quests['q1'] = _buildQuest(visualKey: 'fitness/walk_20'),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness('q1', overrides));
        await tester.pumpAndSettle();

        final image = tester.widget<Image>(find.byType(Image));
        expect(
          (image.image as AssetImage).assetName,
          'assets/visuals/walking.png',
        );
      },
    );

    testWidgets(
      'hero falls back to the gradient placeholder for a hand-typed quest '
      'with no visualKey',
      (tester) async {
        final overrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness('q1', overrides));
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'quantity quest primary CTA reads Begin before any progress, then '
      'Continue once some exists',
      (tester) async {
        _growViewport(tester);
        final overrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository()
            ..quests['q1'] = _buildQuest(
              progressType: ProgressType.quantity,
              targetProgress: 8,
            ),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness('q1', overrides));
        await tester.pumpAndSettle();

        expect(find.text('Begin'), findsOneWidget);
        expect(find.text('Continue'), findsNothing);

        await tester.tap(find.text('Begin'));
        await tester.pumpAndSettle();

        // The CTA's own `+1` landed, same as the stepper's `+1` would have.
        expect(find.text('1 / 8'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
        expect(find.text('Begin'), findsNothing);
      },
    );

    testWidgets('duration quest primary CTA adds progress through the same '
        'controller the quick-add buttons use, and disappears once complete', (
      tester,
    ) async {
      _growViewport(tester);
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = _buildQuest(
            progressType: ProgressType.duration,
            targetProgress: 5,
          ),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness('q1', overrides));
      await tester.pumpAndSettle();

      expect(find.text('Begin'), findsOneWidget);

      await tester.tap(find.text('Begin'));
      await tester.pumpAndSettle();

      // 5-minute step clamps to the 5-minute target and completes it —
      // once complete, neither Begin nor Continue is shown anymore.
      expect(find.text('5 / 5 min'), findsOneWidget);
      expect(find.text('Begin'), findsNothing);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('quantity quest shown as finished once complete: bar full, no '
        'primary CTA, no crash', (tester) async {
      _growViewport(tester);
      final progressRepository = FakeQuestProgressRepository()
        ..entries.add(
          QuestProgress(
            questId: 'q1',
            date: _today,
            progressValue: 8,
            isComplete: true,
          ),
        );
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = _buildQuest(
            progressType: ProgressType.quantity,
            targetProgress: 8,
          ),
        questProgressRepository: progressRepository,
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness('q1', overrides));
      await tester.pumpAndSettle();

      expect(find.text('8 / 8'), findsOneWidget);
      expect(find.text('Begin'), findsNothing);
      expect(find.text('Continue'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Turkish: hero, CTA, and Rewards all localize', (
      tester,
    ) async {
      _growViewport(tester);
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = _buildQuest(
            title: 'Egzersiz yap',
            description: 'Spor salonuna git',
            progressType: ProgressType.quantity,
            targetProgress: 8,
          ),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(
        _harness('q1', overrides, locale: const Locale('tr')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Egzersiz yap'), findsWidgets); // AppBar + hero
      expect(find.text('Başla'), findsOneWidget); // Begin
      expect(find.text('Kazanımlar'), findsOneWidget); // Rewards header
      expect(find.text('Neden önemli'), findsOneWidget); // Why this matters
      expect(find.text('Normal'), findsWidgets); // difficulty, unchanged
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in English: CTA and Rewards header are English', (
      tester,
    ) async {
      _growViewport(tester);
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = _buildQuest(
            progressType: ProgressType.quantity,
            targetProgress: 8,
          ),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(
        _harness('q1', overrides, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Begin'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Why this matters'), findsOneWidget);
    });

    testWidgets(
      'a long Turkish quest title renders without overflow at 360px width',
      (tester) async {
        _growViewport(tester, width: 360, height: 1400);

        const longTurkishTitle =
            'Dağıtık sistemler hakkında çok uzun bir kitabın tam bir '
            'bölümünü her sabah işe gitmeden önce oku';
        final overrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository()
            ..quests['q1'] = _buildQuest(
              title: longTurkishTitle,
              progressType: ProgressType.duration,
              targetProgress: 30,
            ),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(
          _harness('q1', overrides, locale: const Locale('tr')),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '360px width with every section present (hero, progress, primary '
      'action, rewards, why this matters) renders without overflow',
      (tester) async {
        _growViewport(tester, width: 360, height: 1600);

        final overrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository()
            ..quests['q1'] = _buildQuest(
              visualKey: 'fitness/walk_20',
              progressType: ProgressType.quantity,
              targetProgress: 8,
            ),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness('q1', overrides));
        await tester.pumpAndSettle();

        expect(find.text('Rewards'), findsOneWidget);
        expect(find.text('Why this matters'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'a quest with no description renders no Why-this-matters section — '
      'never invents motivational copy',
      (tester) async {
        final overrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository()
            ..quests['q1'] = _buildQuest(description: ''),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness('q1', overrides));
        await tester.pumpAndSettle();

        expect(find.text('Why this matters'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
