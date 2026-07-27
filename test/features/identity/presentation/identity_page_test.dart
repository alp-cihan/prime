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

Widget _harness(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: IdentityPage()),
  );
}

/// The full Identity page (profile + attributes + lifetime + timeline)
/// overflows the default test viewport — grown here so every section's
/// assertions can find their widgets without needing to scroll first.
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
  testWidgets('renders an empty profile with placeholder timeline text', (
    tester,
  ) async {
    _growViewport(tester);

    await tester.pumpWidget(_harness(_overrides()));
    await tester.pumpAndSettle();

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('0 XP'), findsWidgets); // header + every attribute tile
    expect(
      find.text(
        'No milestones yet — complete quests to start building your story.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders lifetime XP, level, and attribute breakdown', (
    tester,
  ) async {
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

    expect(find.text('80 XP'), findsOneWidget); // lifetime total in the header
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('Strongest'), findsOneWidget);
    expect(find.text('Weakest'), findsOneWidget);
  });

  testWidgets('renders lifetime statistics tiles', (tester) async {
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

    expect(find.text('Quests completed'), findsOneWidget);
    expect(find.text('1'), findsWidgets); // 1 quest, 1 achievement
    expect(find.text('Achievements unlocked'), findsOneWidget);
  });

  testWidgets('renders a milestone in the timeline when one exists', (
    tester,
  ) async {
    _growViewport(tester);
    final unlocks = FakeAchievementUnlockRepository()
      ..unlocks['first_step'] = AchievementUnlock(
        achievementId: 'first_step',
        unlockedAt: DateTime.utc(2026, 3, 5),
      );

    await tester.pumpWidget(_harness(_overrides(unlocks: unlocks)));
    await tester.pumpAndSettle();

    expect(find.text('Unlocked "First Step"'), findsOneWidget);
    expect(find.textContaining('2026-03-05'), findsOneWidget);
  });

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
}
