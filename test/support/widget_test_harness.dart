import 'package:prime/features/achievements/presentation/providers/achievement_repository_providers.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import 'fake_repositories.dart';

/// Standard fake-backed overrides for Phase 5+ widget tests — no Hive, no
/// temp directories. [today] backs [clockProvider] (and therefore
/// `todayUtcProvider`), so "today" is deterministic in every test.
/// [achievementUnlockRepository] defaults to a fresh, empty fake so existing
/// call sites (predating Phase 10) don't need to pass one — the
/// achievements feature's shell-level evaluation listener
/// (`ScaffoldWithNavBar`) needs *some* `AchievementUnlockRepository`
/// available any time `PrimeApp`/the shell is mounted, real or fake.
List<Override> fakeProviderOverrides({
  required FakeQuestRepository questRepository,
  required FakeQuestProgressRepository questProgressRepository,
  required FakeXpLedgerRepository xpLedgerRepository,
  required DateTime today,
  FakeAchievementUnlockRepository? achievementUnlockRepository,
}) {
  return [
    questRepositoryProvider.overrideWithValue(questRepository),
    questProgressRepositoryProvider.overrideWithValue(questProgressRepository),
    xpLedgerRepositoryProvider.overrideWithValue(xpLedgerRepository),
    achievementUnlockRepositoryProvider.overrideWithValue(
      achievementUnlockRepository ?? FakeAchievementUnlockRepository(),
    ),
    clockProvider.overrideWithValue(FakeClock(today)),
  ];
}
