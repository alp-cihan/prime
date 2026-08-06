import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';
import 'package:prime/features/achievements/presentation/achievements_page.dart';
import 'package:prime/features/achievements/presentation/providers/achievement_repository_providers.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/test_localizations.dart';

Widget _harness(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      home: AchievementsPage(),
    ),
  );
}

/// The full 7-entry catalog (plus the summary header and section labels)
/// overflows the default test viewport, so `ListView` only builds its
/// visible children — grown here so every row assertion below can find its
/// widget without needing to scroll first.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

XpTransaction _questTx(
  String questId,
  String dateKey, {
  double difficulty = 1.0,
}) {
  final sourceId = '$questId|$dateKey|0';
  return XpTransaction(
    id: '$sourceId|health',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: AttributeType.health,
    baseXp: 100,
    modifiersApplied: {'difficulty': difficulty},
    finalXp: 100,
    createdAt: DateTime.utc(2026, 1, 10),
    idempotencyKey: '$sourceId|health',
  );
}

void main() {
  testWidgets('shows the unlocked/total summary', (tester) async {
    _growViewport(tester);
    final unlocks = FakeAchievementUnlockRepository()
      ..unlocks['first_step'] = AchievementUnlock(
        achievementId: 'first_step',
        unlockedAt: DateTime.utc(2026, 1, 10),
      );

    await tester.pumpWidget(
      _harness([
        achievementUnlockRepositoryProvider.overrideWithValue(unlocks),
        xpLedgerRepositoryProvider.overrideWithValue(FakeXpLedgerRepository()),
      ]),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('1 / 7'),
      findsOneWidget,
    ); // 7-entry built-in catalog
  });

  testWidgets('unlocked section shows title, description, and unlock date', (
    tester,
  ) async {
    _growViewport(tester);
    final unlocks = FakeAchievementUnlockRepository()
      ..unlocks['first_step'] = AchievementUnlock(
        achievementId: 'first_step',
        unlockedAt: DateTime.utc(2026, 3, 5),
      );

    await tester.pumpWidget(
      _harness([
        achievementUnlockRepositoryProvider.overrideWithValue(unlocks),
        xpLedgerRepositoryProvider.overrideWithValue(FakeXpLedgerRepository()),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('First Step'), findsOneWidget);
    expect(find.text('Complete your first quest.'), findsOneWidget);
    // Phase 17.3: the unlock date now renders through
    // `MaterialLocalizations.formatMediumDate` (locale-aware) instead of a
    // hardcoded ISO string — assert on the year rather than an exact format
    // that's no longer guaranteed stable across locales/Flutter versions.
    expect(find.textContaining('2026'), findsOneWidget);
  });

  testWidgets(
    'locked, non-hidden achievements show their real title and progress',
    (tester) async {
      _growViewport(tester);
      final ledger = FakeXpLedgerRepository()
        ..byKey['a'] = _questTx('q1', '2026-01-10');

      await tester.pumpWidget(
        _harness([
          achievementUnlockRepositoryProvider.overrideWithValue(
            FakeAchievementUnlockRepository(),
          ),
          xpLedgerRepositoryProvider.overrideWithValue(ledger),
        ]),
      );
      await tester.pumpAndSettle();

      // "Getting Started" (5 completions) is locked but not hidden — its real
      // title/description must be visible.
      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Complete 5 quests.'), findsOneWidget);
    },
  );

  testWidgets('a hidden, locked achievement shows only "Hidden Achievement"', (
    tester,
  ) async {
    _growViewport(tester);
    await tester.pumpWidget(
      _harness([
        achievementUnlockRepositoryProvider.overrideWithValue(
          FakeAchievementUnlockRepository(),
        ),
        xpLedgerRepositoryProvider.overrideWithValue(FakeXpLedgerRepository()),
      ]),
    );
    await tester.pumpAndSettle();

    // "Challenger" is hiddenUntilUnlocked in the built-in catalog.
    expect(find.text('Hidden Achievement'), findsOneWidget);
    expect(find.text('Challenger'), findsNothing);
    expect(find.text('Complete a Hard or Very Hard quest.'), findsNothing);
  });

  testWidgets(
    'once unlocked, a previously-hidden achievement reveals its real title',
    (tester) async {
      _growViewport(tester);
      final unlocks = FakeAchievementUnlockRepository()
        ..unlocks['challenger'] = AchievementUnlock(
          achievementId: 'challenger',
          unlockedAt: DateTime.utc(2026, 1, 10),
        );

      await tester.pumpWidget(
        _harness([
          achievementUnlockRepositoryProvider.overrideWithValue(unlocks),
          xpLedgerRepositoryProvider.overrideWithValue(
            FakeXpLedgerRepository(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Challenger'), findsOneWidget);
      expect(find.text('Hidden Achievement'), findsNothing);
    },
  );
}
