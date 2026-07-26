import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import 'fake_repositories.dart';

/// Standard fake-backed overrides for Phase 5 widget tests — no Hive, no
/// temp directories. [today] backs [clockProvider] (and therefore
/// `todayUtcProvider`), so "today" is deterministic in every test.
List<Override> fakeProviderOverrides({
  required FakeQuestRepository questRepository,
  required FakeQuestProgressRepository questProgressRepository,
  required FakeXpLedgerRepository xpLedgerRepository,
  required DateTime today,
}) {
  return [
    questRepositoryProvider.overrideWithValue(questRepository),
    questProgressRepositoryProvider.overrideWithValue(questProgressRepository),
    xpLedgerRepositoryProvider.overrideWithValue(xpLedgerRepository),
    clockProvider.overrideWithValue(FakeClock(today)),
  ];
}
