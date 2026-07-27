import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/achievements/presentation/achievements_page.dart';
import '../../features/chains/presentation/chain_detail_page.dart';
import '../../features/chains/presentation/chains_page.dart';
import '../../features/focus/presentation/focus_page.dart';
import '../../features/identity/presentation/identity_page.dart';
import '../../features/journal/presentation/journal_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/onboarding/presentation/providers/onboarding_providers.dart';
import '../../features/quests/presentation/pages/quest_form_page.dart';
import '../../features/quests/presentation/quest_detail_page.dart';
import '../../features/quests/presentation/quests_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/story/presentation/story_page.dart';
import '../../features/today/presentation/today_page.dart';
import '../../features/you/presentation/you_page.dart';
import 'app_routes.dart';
import 'scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

/// The app's single [GoRouter] instance. Generated as a Riverpod provider
/// (rather than a bare top-level constant) so later phases can inject
/// auth/onboarding redirects without changing how the router is consumed.
///
/// Phase 14 onboarding gate: [AppRoutes.onboarding] is the initial location
/// exactly when [OnboardingRepository.isCompleted] is still false (a
/// synchronous read — see that repository's own doc for why); [redirect]
/// re-checks the *current* value (via `ref.read`, not a captured one) on
/// every navigation attempt, so a user who has never completed onboarding
/// can't reach a shell route by deep-linking around it, while a completed
/// user visiting `/onboarding` again (Settings' "Restart Onboarding") is
/// never redirected away from it.
@riverpod
GoRouter appRouter(Ref ref) {
  final onboardingRepository = ref.watch(onboardingRepositoryProvider);

  return GoRouter(
    initialLocation: onboardingRepository.isCompleted()
        ? AppRoutes.today
        : AppRoutes.onboarding,
    redirect: (context, state) {
      final completed = ref.read(onboardingRepositoryProvider).isCompleted();
      final goingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!completed && !goingToOnboarding) return AppRoutes.onboarding;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) => const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.quests,
                builder: (context, state) => const QuestsPage(),
                routes: [
                  // Nested under the quests branch (not a separate shell
                  // destination) so detail/form screens keep the bottom nav
                  // visible and share this branch's own navigation stack —
                  // per docs/architecture.md §19 and the
                  // StatefulShellRoute.indexedStack pattern already in use.
                  //
                  // `new` is declared *before* `:questId` — go_router tries
                  // sibling routes in declaration order, so `/quests/new`
                  // resolves to this literal route rather than being
                  // captured as `:questId = "new"`.
                  GoRoute(
                    path: AppRoutes.questNewSegment,
                    builder: (context, state) => const QuestFormPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.questDetailSegment,
                    builder: (context, state) {
                      final questId = state.pathParameters['questId']!;
                      return QuestDetailPage(questId: questId);
                    },
                    routes: [
                      GoRoute(
                        path: AppRoutes.questEditSegment,
                        builder: (context, state) {
                          final questId = state.pathParameters['questId']!;
                          return QuestFormPage(questId: questId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.story,
                builder: (context, state) => const StoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.journal,
                builder: (context, state) => const JournalPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.you,
                builder: (context, state) => const YouPage(),
                routes: [
                  // Nested under the You branch (not a separate shell
                  // destination) so the bottom nav stays visible — same
                  // pattern as the quests branch's detail/edit routes.
                  GoRoute(
                    path: AppRoutes.achievementsSegment,
                    builder: (context, state) => const AchievementsPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.chainsSegment,
                    builder: (context, state) => const ChainsPage(),
                    routes: [
                      GoRoute(
                        path: AppRoutes.chainDetailSegment,
                        builder: (context, state) {
                          final chainId = state.pathParameters['chainId']!;
                          return ChainDetailPage(chainId: chainId);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: AppRoutes.identitySegment,
                    builder: (context, state) => const IdentityPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.settingsSegment,
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Outside the shell — Focus Mode must never live in the tab chrome.
      GoRoute(
        path: AppRoutes.focus,
        builder: (context, state) => const FocusPage(),
      ),
    ],
  );
}
