import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';
import 'package:prime/features/achievements/presentation/providers/achievement_repository_providers.dart';
import 'package:prime/features/chains/presentation/providers/chain_repository_providers.dart';
import 'package:prime/features/identity/presentation/identity_page.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/domain/repositories/xp_ledger_repository.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/test_localizations.dart';

class _ThrowingXpLedgerRepository implements XpLedgerRepository {
  @override
  Future<void> appendAll(List<XpTransaction> transactions) async =>
      throw StateError('ledger unavailable');

  @override
  Future<List<XpTransaction>> getAll() async =>
      throw StateError('ledger unavailable');

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
  Future<int> sumLifetimeXp() async => throw UnimplementedError();

  @override
  Future<int> sumXpForAttribute(AttributeType type) async =>
      throw UnimplementedError();
}

Widget _harness(
  List<Override> overrides, {
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      home: const IdentityPage(),
    ),
  );
}

/// The full Identity page (hero + attributes + balance + journey +
/// timeline) overflows the default test viewport — grown here so every
/// section's assertions can find their widgets without needing to scroll.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

XpTransaction _questTx(
  String questId,
  String dateKey, {
  AttributeType attribute = AttributeType.health,
  int finalXp = 100,
}) {
  final sourceId = '$questId|$dateKey|0';
  return XpTransaction(
    id: '$sourceId|${attribute.name}',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: attribute,
    baseXp: finalXp,
    modifiersApplied: const {'difficulty': 1.0},
    finalXp: finalXp,
    createdAt: DateTime.utc(2026, 1, 10),
    idempotencyKey: '$sourceId|${attribute.name}',
  );
}

List<Override> _overrides({
  FakeXpLedgerRepository? ledger,
  FakeAchievementUnlockRepository? unlocks,
  FakeChainProgressRepository? chainProgress,
}) {
  return [
    xpLedgerRepositoryProvider.overrideWithValue(
      ledger ?? FakeXpLedgerRepository(),
    ),
    achievementUnlockRepositoryProvider.overrideWithValue(
      unlocks ?? FakeAchievementUnlockRepository(),
    ),
    chainProgressRepositoryProvider.overrideWithValue(
      chainProgress ?? FakeChainProgressRepository(),
    ),
  ];
}

void main() {
  testWidgets(
    'renders an empty profile with a zero-XP balance hint and placeholder timeline',
    (tester) async {
      _growViewport(tester);

      await tester.pumpWidget(_harness(_overrides()));
      await tester.pumpAndSettle();

      // Dominant level number in the hero.
      expect(find.text('1'), findsOneWidget);
      // Every attribute card at zero XP.
      expect(find.text('0 XP'), findsNWidgets(8));
      expect(
        find.text('Complete a quest to see your balance take shape.'),
        findsOneWidget,
      );
      expect(
        find.text('Complete your first quest to begin your story.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'No milestones yet — complete quests to start building your story.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'renders lifetime XP, level, strongest message, and attribute breakdown',
    (tester) async {
      _growViewport(tester);
      final ledger = FakeXpLedgerRepository()
        ..byKey['a'] = _questTx(
          'q1',
          '2026-01-10',
          attribute: AttributeType.health,
          finalXp: 60,
        )
        ..byKey['b'] = _questTx(
          'q1',
          '2026-01-10',
          attribute: AttributeType.strength,
          finalXp: 20,
        );

      await tester.pumpWidget(_harness(_overrides(ledger: ledger)));
      await tester.pumpAndSettle();

      expect(find.text('80 XP total'), findsOneWidget); // hero lifetime total
      expect(find.text('Currently strongest: Health'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Strongest'), findsOneWidget);
      expect(find.text('Weakest'), findsOneWidget);
      // Balance section has real data, so its empty hint must not render.
      expect(
        find.text('Complete a quest to see your balance take shape.'),
        findsNothing,
      );
    },
  );

  testWidgets('renders all eight attributes', (tester) async {
    _growViewport(tester);

    await tester.pumpWidget(_harness(_overrides()));
    await tester.pumpAndSettle();

    for (final name in [
      'Health',
      'Strength',
      'Discipline',
      'Knowledge',
      'Career',
      'Finance',
      'Relationships',
      'Mindfulness',
    ]) {
      expect(find.text(name), findsOneWidget);
    }
  });

  testWidgets('renders Your Journey stats', (tester) async {
    _growViewport(tester);
    final ledger = FakeXpLedgerRepository()
      ..byKey['a'] = _questTx('q1', '2026-01-10');
    final unlocks = FakeAchievementUnlockRepository()
      ..unlocks['first_step'] = AchievementUnlock(
        achievementId: 'first_step',
        unlockedAt: DateTime.utc(2026, 1, 10),
      );

    await tester.pumpWidget(
      _harness(_overrides(ledger: ledger, unlocks: unlocks)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Journey'), findsOneWidget);
    expect(find.text('Quests completed'), findsOneWidget);
    expect(find.text('Achievements unlocked'), findsOneWidget);
    expect(find.text('Chains completed'), findsOneWidget);
    expect(find.text('Total XP earned'), findsOneWidget);
    expect(find.text('Day streak'), findsOneWidget);
  });

  testWidgets(
    'renders a milestone with its achievement description in the timeline',
    (tester) async {
      _growViewport(tester);
      final unlocks = FakeAchievementUnlockRepository()
        ..unlocks['first_step'] = AchievementUnlock(
          achievementId: 'first_step',
          unlockedAt: DateTime.utc(2026, 3, 5),
        );

      await tester.pumpWidget(_harness(_overrides(unlocks: unlocks)));
      await tester.pumpAndSettle();

      expect(find.text('Unlocked "First Step"'), findsOneWidget);
      expect(find.text('Complete your first quest.'), findsOneWidget);
      // Phase 17.3: the milestone date now renders through
      // `MaterialLocalizations.formatMediumDate` (locale-aware) instead of a
      // hardcoded ISO string — assert on the year rather than an exact format
      // that's no longer guaranteed stable across locales/Flutter versions.
      expect(find.textContaining('2026'), findsOneWidget);
    },
  );

  testWidgets('shows a retryable error state when loading fails', (
    tester,
  ) async {
    _growViewport(tester);

    await tester.pumpWidget(
      _harness([
        xpLedgerRepositoryProvider.overrideWithValue(
          _ThrowingXpLedgerRepository(),
        ),
        achievementUnlockRepositoryProvider.overrideWithValue(
          FakeAchievementUnlockRepository(),
        ),
        chainProgressRepositoryProvider.overrideWithValue(
          FakeChainProgressRepository(),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining("Couldn't load your identity profile"),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
  });

  testWidgets('renders Turkish localization across every section', (
    tester,
  ) async {
    _growViewport(tester);
    final ledger = FakeXpLedgerRepository()
      ..byKey['a'] = _questTx(
        'q1',
        '2026-01-10',
        attribute: AttributeType.health,
        finalXp: 60,
      );
    final unlocks = FakeAchievementUnlockRepository()
      ..unlocks['first_step'] = AchievementUnlock(
        achievementId: 'first_step',
        unlockedAt: DateTime.utc(2026, 1, 10),
      );

    await tester.pumpWidget(
      _harness(
        _overrides(ledger: ledger, unlocks: unlocks),
        locale: const Locale('tr'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SEN'), findsOneWidget); // uppercased hero eyebrow
    expect(find.text('Denge'), findsOneWidget); // balance header
    expect(find.text('Yolculuğun'), findsOneWidget); // journey header
    expect(find.text('Nitelikler'), findsOneWidget); // attributes header
    expect(find.text('Şu anda en güçlü: Sağlık'), findsOneWidget);
    expect(find.text('Gün serisi'), findsOneWidget); // streak label
  });

  testWidgets('renders long Turkish strings without overflow at 360px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 690); // a small phone
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ledger = FakeXpLedgerRepository()
      ..byKey['a'] = _questTx(
        'q1',
        '2026-01-10',
        attribute: AttributeType.health,
        finalXp: 60000,
      )
      ..byKey['b'] = _questTx(
        'q1',
        '2026-01-10',
        attribute: AttributeType.strength,
        finalXp: 20000,
      );
    final unlocks = FakeAchievementUnlockRepository()
      ..unlocks['first_step'] = AchievementUnlock(
        achievementId: 'first_step',
        unlockedAt: DateTime.utc(2026, 1, 10),
      );

    await tester.pumpWidget(
      _harness(
        _overrides(ledger: ledger, unlocks: unlocks),
        locale: const Locale('tr'),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'renders a populated profile without overflow on a narrow phone viewport',
    (tester) async {
      tester.view.physicalSize = const Size(360, 690); // a small phone
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ledger = FakeXpLedgerRepository()
        ..byKey['a'] = _questTx(
          'q1',
          '2026-01-10',
          attribute: AttributeType.health,
          finalXp: 60000,
        )
        ..byKey['b'] = _questTx(
          'q1',
          '2026-01-10',
          attribute: AttributeType.strength,
          finalXp: 20000,
        );
      final unlocks = FakeAchievementUnlockRepository()
        ..unlocks['first_step'] = AchievementUnlock(
          achievementId: 'first_step',
          unlockedAt: DateTime.utc(2026, 1, 10),
        );

      await tester.pumpWidget(
        _harness(_overrides(ledger: ledger, unlocks: unlocks)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows level progress text toward the next level', (
    tester,
  ) async {
    _growViewport(tester);
    final ledger = FakeXpLedgerRepository()
      ..byKey['a'] = _questTx(
        'q1',
        '2026-01-10',
        attribute: AttributeType.health,
        finalXp: 60,
      );

    await tester.pumpWidget(_harness(_overrides(ledger: ledger)));
    await tester.pumpAndSettle();

    expect(find.textContaining('/'), findsWidgets);
  });
}
