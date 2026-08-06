import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/app.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/localization/app_locale_option.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';

import '../support/fake_repositories.dart';
import '../support/widget_test_harness.dart';

Quest _buildTestQuest() {
  return Quest(
    id: 'q1',
    title: 'Egzersiz',
    description: '',
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

/// Phase 17.3 — Turkish/English localization. Covers device-locale
/// detection, explicit-choice persistence, live switching, and a few
/// screen-level spot checks (Settings' language selector already gets its
/// own dedicated coverage in `settings_page_test.dart`).
void main() {
  void growViewport(
    WidgetTester tester, {
    double width = 800,
    double height = 3000,
  }) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    List<Locale>? deviceLocales,
    AppLocaleOption? savedOption,
  }) async {
    if (deviceLocales != null) {
      tester.platformDispatcher.localesTestValue = deviceLocales;
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    }

    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
      localeRepository: savedOption == null
          ? null
          : FakeLocaleRepository(option: savedOption),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const PrimeApp()),
    );
    await tester.pumpAndSettle();
  }

  group('device-locale detection (System mode, no explicit choice)', () {
    testWidgets('a Turkish device locale selects Turkish', (tester) async {
      await pumpApp(tester, deviceLocales: const [Locale('tr')]);

      expect(find.text('Bugün'), findsWidgets); // Today, nav label + title
      expect(find.text('Görevler'), findsOneWidget); // Quests
      expect(find.text('Today'), findsNothing);
    });

    testWidgets(
      'an unsupported device locale falls back to English (listed first '
      'in supportedLocales)',
      (tester) async {
        await pumpApp(tester, deviceLocales: const [Locale('fr')]);

        expect(find.text('Today'), findsWidgets);
        expect(find.text('Quests'), findsOneWidget);
        expect(find.text('Bugün'), findsNothing);
      },
    );

    testWidgets('an English device locale selects English', (tester) async {
      await pumpApp(tester, deviceLocales: const [Locale('en')]);

      expect(find.text('Today'), findsWidgets);
      expect(find.text('Bugün'), findsNothing);
    });
  });

  group('explicit choice overrides the device locale and persists', () {
    testWidgets('an explicit Turkish choice wins even on an English device', (
      tester,
    ) async {
      await pumpApp(
        tester,
        deviceLocales: const [Locale('en')],
        savedOption: AppLocaleOption.turkish,
      );

      expect(find.text('Bugün'), findsWidgets);
      expect(find.text('Today'), findsNothing);
    });

    testWidgets('an explicit English choice wins even on a Turkish device', (
      tester,
    ) async {
      await pumpApp(
        tester,
        deviceLocales: const [Locale('tr')],
        savedOption: AppLocaleOption.english,
      );

      expect(find.text('Today'), findsWidgets);
      expect(find.text('Bugün'), findsNothing);
    });

    testWidgets(
      'a persisted choice is read back from the repository on the next launch',
      (tester) async {
        final repository = FakeLocaleRepository(
          option: AppLocaleOption.turkish,
        );

        // First "launch".
        final firstOverrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository(),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: DateTime.utc(2026, 1, 10),
          localeRepository: repository,
        );
        await tester.pumpWidget(
          ProviderScope(overrides: firstOverrides, child: const PrimeApp()),
        );
        await tester.pumpAndSettle();
        expect(find.text('Bugün'), findsWidgets);
        await tester.pumpWidget(const SizedBox.shrink());

        // Second "launch" (a fresh container), reading the same
        // externally-owned repository the first one persisted into.
        final secondOverrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository(),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: DateTime.utc(2026, 1, 10),
          localeRepository: repository,
        );
        await tester.pumpWidget(
          ProviderScope(overrides: secondOverrides, child: const PrimeApp()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Bugün'), findsWidgets);
      },
    );
  });

  group('live switching', () {
    testWidgets(
      'changing the language via Settings updates the UI immediately, '
      'without a restart',
      (tester) async {
        growViewport(tester);
        await pumpApp(tester, deviceLocales: const [Locale('en')]);
        expect(find.text('Today'), findsWidgets);

        await tester.tap(find.text('You'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Türkçe'), findsOneWidget);

        await tester.tap(find.text('Türkçe'));
        await tester.pumpAndSettle();

        // Same screen, same widget tree, no navigation — just relabeled.
        expect(find.text('Ayarlar'), findsOneWidget);
        expect(find.text('Settings'), findsNothing);

        // The bottom nav (owned by the shell, well outside Settings' own
        // subtree) picks it up too, proving this isn't a one-screen fluke.
        expect(find.text('Sen'), findsOneWidget); // You
      },
    );

    testWidgets('switching back to System re-follows the device locale', (
      tester,
    ) async {
      growViewport(tester);
      await pumpApp(
        tester,
        deviceLocales: const [Locale('tr')],
        savedOption: AppLocaleOption.english,
      );
      expect(find.text('Today'), findsWidgets);

      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Starting point is the explicit English choice, so the selector's
      // own label is still in English at this point.
      await tester.tap(find.text('System language'));
      await tester.pumpAndSettle();

      expect(find.text('Ayarlar'), findsOneWidget); // back to the TR device
      expect(find.text('Settings'), findsNothing);
    });
  });

  group('screen spot checks in Turkish', () {
    testWidgets('Today dashboard renders in Turkish', (tester) async {
      growViewport(tester);
      await pumpApp(tester, deviceLocales: const [Locale('tr')]);

      expect(find.text('Bugün'), findsWidgets); // nav label + page title
      expect(find.text('Günlük ivme'), findsOneWidget); // Daily momentum
      expect(find.text('Bugünkü gelişim'), findsOneWidget); // Growth today
    });

    testWidgets('the Quests empty state and create-quest form are Turkish', (
      tester,
    ) async {
      await pumpApp(tester, deviceLocales: const [Locale('tr')]);

      await tester.tap(find.text('Görevler'));
      await tester.pumpAndSettle();

      expect(
        find.text('Henüz görev yok. Oluşturduğunuz görevler burada görünecek.'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Görev Oluştur'));
      await tester.pumpAndSettle();

      expect(find.text('Yeni Görev'), findsOneWidget); // New Quest
      expect(find.text('Başlık'), findsOneWidget); // Title
      expect(find.text('Açıklama'), findsOneWidget); // Description
      expect(find.text('Görev Oluştur'), findsOneWidget); // Create Quest
    });

    testWidgets('Suggestions renders in Turkish', (tester) async {
      await pumpApp(tester, deviceLocales: const [Locale('tr')]);

      await tester.tap(find.text('Görevler'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Öneriler'));
      await tester.pumpAndSettle();

      expect(find.text('Öneriler'), findsOneWidget); // Suggestions (AppBar)
      expect(
        find.text('Başlamak için popüler görevler'),
        findsOneWidget,
      ); // Popular quests to start with (no profile set yet)
    });

    testWidgets('the delete-quest confirmation dialog renders in Turkish', (
      tester,
    ) async {
      final quest = FakeQuestRepository()..quests['q1'] = _buildTestQuest();
      final overrides = fakeProviderOverrides(
        questRepository: quest,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: DateTime.utc(2026, 1, 10),
        localeRepository: FakeLocaleRepository(option: AppLocaleOption.turkish),
      );

      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const PrimeApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Görevler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Egzersiz'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Görev silinsin mi?'), findsOneWidget);
      expect(find.text('Vazgeç'), findsOneWidget); // Cancel
      expect(find.text('Sil'), findsOneWidget); // Delete
    });
  });

  group('narrow-width overflow', () {
    testWidgets(
      'the quest form does not overflow at 360px width with Turkish strings',
      (tester) async {
        growViewport(tester, width: 360, height: 800);

        await pumpApp(tester, deviceLocales: const [Locale('tr')]);

        await tester.tap(find.text('Görevler'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Görev Oluştur'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Settings does not overflow at 360px width with Turkish strings',
      (tester) async {
        growViewport(tester, width: 360, height: 1200);

        await pumpApp(tester, deviceLocales: const [Locale('tr')]);

        await tester.tap(find.text('Sen'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ayarlar'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
