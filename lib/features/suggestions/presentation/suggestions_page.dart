import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../application/models/create_quest_from_suggestion_outcome.dart';
import '../domain/entities/recommendation_profile.dart';
import 'providers/ranked_suggestions_provider.dart';
import 'providers/recommendation_profile_controller.dart';
import 'providers/suggestion_filter_controller.dart';
import 'widgets/goal_filter_chips.dart';
import 'widgets/suggestion_card.dart';

/// Phase 16 — the Quest Suggestions browsing screen. Reached from the Quests
/// empty state, the Quests tab's own entry point, Today's empty state,
/// onboarding, and Settings (see each page's own doc comment).
class SuggestionsPage extends ConsumerWidget {
  const SuggestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(recommendationProfileControllerProvider);
    final suggestionsAsync = ref.watch(rankedSuggestionsProvider);
    final filterGoals = ref.watch(suggestionFilterControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.suggestionsTitle),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.suggestionsPreferences),
            icon: const Icon(Icons.tune),
            tooltip: l10n.preferencesTooltip,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: _Heading(profile: profileAsync.value),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GoalFilterChips(
                selected: filterGoals,
                onToggle: (goal) => ref
                    .read(suggestionFilterControllerProvider.notifier)
                    .toggle(goal),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: suggestionsAsync.when(
                data: (suggestions) {
                  if (suggestions.isEmpty) {
                    return const _EmptySuggestions();
                  }
                  // Single-column, image-forward list — each card sizes
                  // itself from its own content (see SuggestionCard's own
                  // doc comment for the height/ratio reasoning), so this is
                  // a plain vertical list, not a grid.
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    itemCount: suggestions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      return SuggestionCard(
                        suggestion: suggestion,
                        onTap: () => context.push(
                          AppRoutes.suggestionDetail(suggestion.id),
                        ),
                        onAdded: (outcome) =>
                            _showAddedFeedback(context, outcome),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  debugPrint('Ranked suggestions failed to load: $error');
                  return _EmptySuggestions(
                    message: l10n.couldntLoadSuggestions,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddedFeedback(
    BuildContext context,
    CreateQuestFromSuggestionOutcome outcome,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final message = switch (outcome) {
      SuggestionQuestCreated() => l10n.addedToQuests(outcome.quest.title),
      SuggestionAlreadyAdded() => l10n.alreadyInQuests(outcome.quest.title),
    };
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: l10n.openLabel,
          onPressed: () => context.go(AppRoutes.questDetail(outcome.quest.id)),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.profile});

  final RecommendationProfile? profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPersonalized = profile?.isPersonalized ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPersonalized ? l10n.pickedForYou : l10n.popularQuestsToStart,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isPersonalized ? l10n.basedOnGoals : l10n.setPreferencesForPicks,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _EmptySuggestions extends StatelessWidget {
  const _EmptySuggestions({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          message ?? AppLocalizations.of(context)!.noSuggestionsLeft,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.darkTextSecondary),
        ),
      ),
    );
  }
}
