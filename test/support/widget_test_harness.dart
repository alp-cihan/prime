import 'package:prime/features/achievements/presentation/providers/achievement_repository_providers.dart';
import 'package:prime/features/chains/presentation/providers/chain_repository_providers.dart';
import 'package:prime/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:prime/features/suggestions/presentation/providers/suggestions_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import 'fake_repositories.dart';

/// Standard fake-backed overrides for Phase 5+ widget tests — no Hive, no
/// temp directories. [today] backs [clockProvider] (and therefore
/// `todayUtcProvider`), so "today" is deterministic in every test.
/// [achievementUnlockRepository]/[chainProgressRepository] each default to a
/// fresh, empty fake so existing call sites don't need to pass one — the
/// achievements/chains features' shell-level evaluation controllers
/// (`ScaffoldWithNavBar`) need *some* repository available any time
/// `PrimeApp`/the shell is mounted, real or fake. The chain catalog is
/// empty by default in production, so an empty fake repository is already
/// exactly the harmless no-op it would be for real.
///
/// [onboardingCompleted] defaults to `true` (Phase 14) — the router redirects
/// to `/onboarding` whenever it's false, and the overwhelming majority of
/// existing widget tests are about some other feature and need to land on
/// real app content immediately; onboarding's own tests pass `false`.
List<Override> fakeProviderOverrides({
  required FakeQuestRepository questRepository,
  required FakeQuestProgressRepository questProgressRepository,
  required FakeXpLedgerRepository xpLedgerRepository,
  required DateTime today,
  FakeAchievementUnlockRepository? achievementUnlockRepository,
  FakeChainProgressRepository? chainProgressRepository,
  FakeRecommendationProfileRepository? recommendationProfileRepository,
  bool onboardingCompleted = true,
}) {
  return [
    questRepositoryProvider.overrideWithValue(questRepository),
    questProgressRepositoryProvider.overrideWithValue(questProgressRepository),
    xpLedgerRepositoryProvider.overrideWithValue(xpLedgerRepository),
    achievementUnlockRepositoryProvider.overrideWithValue(
      achievementUnlockRepository ?? FakeAchievementUnlockRepository(),
    ),
    chainProgressRepositoryProvider.overrideWithValue(
      chainProgressRepository ?? FakeChainProgressRepository(),
    ),
    recommendationProfileRepositoryProvider.overrideWithValue(
      recommendationProfileRepository ?? FakeRecommendationProfileRepository(),
    ),
    onboardingRepositoryProvider.overrideWithValue(
      FakeOnboardingRepository(completed: onboardingCompleted),
    ),
    clockProvider.overrideWithValue(FakeClock(today)),
  ];
}
