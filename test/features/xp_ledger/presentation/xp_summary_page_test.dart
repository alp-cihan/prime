import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';
import 'package:prime/features/xp_ledger/presentation/xp_summary_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/widget_test_harness.dart';

final _today = DateTime.utc(2026, 1, 10);

XpTransaction _tx(
  AttributeType attribute,
  int finalXp, {
  String repeatIndex = '0',
}) {
  final sourceId = 'q1|2026-01-10|$repeatIndex';
  return XpTransaction(
    id: '$sourceId|${attribute.name}',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: attribute,
    baseXp: finalXp,
    modifiersApplied: const {},
    finalXp: finalXp,
    createdAt: _today,
    idempotencyKey: '$sourceId|${attribute.name}',
  );
}

Widget _harness(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: XpSummaryPage()),
  );
}

void main() {
  testWidgets('displays total XP', (tester) async {
    final ledger = FakeXpLedgerRepository()
      ..byKey['a'] = _tx(AttributeType.health, 60)
      ..byKey['b'] = _tx(AttributeType.strength, 90);
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: ledger,
      today: _today,
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.textContaining('150 XP total'), findsOneWidget);
  });

  testWidgets('displays XP grouped by attribute', (tester) async {
    final ledger = FakeXpLedgerRepository()
      ..byKey['a'] = _tx(AttributeType.health, 60)
      ..byKey['b'] = _tx(AttributeType.strength, 90);
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: ledger,
      today: _today,
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Health'), findsOneWidget);
    expect(find.text('60 XP'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('90 XP'), findsOneWidget);
    // Every attribute is listed, even ones with zero XP.
    expect(find.text('Knowledge'), findsOneWidget);
    expect(find.text('0 XP'), findsWidgets);
  });

  testWidgets('displays the level derived from LevelCurve', (tester) async {
    final ledger = FakeXpLedgerRepository()
      ..byKey['a'] = _tx(AttributeType.health, 150);
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: ledger,
      today: _today,
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    // 150 total XP -> level 2 with 50/282 XP into it, per LevelCurve(base:100).
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.textContaining('50 / 282'), findsOneWidget);
  });

  testWidgets('renders a coherent empty state at zero XP', (tester) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.textContaining('0 XP total'), findsOneWidget);
    expect(find.text('0 XP'), findsWidgets); // every attribute tile
  });

  testWidgets('displays a retryable error when a provider fails', (
    tester,
  ) async {
    final overrides = [
      ...fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      ),
      totalXpProvider.overrideWith(
        (ref) => Future<int>.error(Exception('ledger unavailable')),
      ),
    ];

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.textContaining("Couldn't load your XP"), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
  });
}
