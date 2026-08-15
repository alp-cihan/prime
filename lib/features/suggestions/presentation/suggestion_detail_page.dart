import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../application/models/create_quest_from_suggestion_outcome.dart';
import '../../quests/domain/entities/quest.dart';
import '../domain/catalog/quest_suggestion_catalog.dart';
import '../domain/entities/quest_suggestion.dart';
import '../domain/services/suggestion_match_explanation.dart';
import 'providers/recommendation_profile_controller.dart';
import 'providers/suggestion_creation_controller.dart';
import 'providers/suggestions_providers.dart';
import 'suggestion_localization.dart';

/// Preview/detail screen for one catalog suggestion — `/suggestions/:id`.
class SuggestionDetailPage extends ConsumerWidget {
  const SuggestionDetailPage({super.key, required this.suggestionId});

  final String suggestionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestion = questSuggestionCatalog
        .where((s) => s.id == suggestionId)
        .firstOrNull;

    final l10n = AppLocalizations.of(context)!;
    if (suggestion == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.suggestionsTitle)),
        body: const _SuggestionNotFound(),
      );
    }

    ref.listen<AsyncValue<CreateQuestFromSuggestionOutcome?>>(
      suggestionCreationControllerProvider(suggestion.id),
      (previous, next) {
        final outcome = next.value;
        if (next.hasValue && outcome != null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                outcome is SuggestionAlreadyAdded
                    ? l10n.alreadyInQuests(outcome.quest.title)
                    : l10n.addedToQuests(outcome.quest.title),
              ),
              action: SnackBarAction(
                label: l10n.openLabel,
                onPressed: () =>
                    context.go(AppRoutes.questDetail(outcome.quest.id)),
              ),
            ),
          );
        } else if (next.hasError) {
          debugPrint('Add suggestion failed: ${next.error}');
        }
      },
    );

    final creationState = ref.watch(
      suggestionCreationControllerProvider(suggestion.id),
    );
    final profileAsync = ref.watch(recommendationProfileControllerProvider);
    final policy = ref.watch(suggestionRankingPolicyProvider);
    final baseXp = suggestion.attributeXpWeights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          suggestionTitle(context, suggestion.id),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestVisual(
              seed: suggestion.visualKey,
              icon: attributeIcon(suggestion.primaryAttribute),
              height: 180,
              borderRadius: BorderRadius.zero,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestionDescription(context, suggestion.id),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (suggestionMotivation(context, suggestion.id)
                      case final motivation?) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      motivation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkTextSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _FactsCard(suggestion: suggestion, baseXp: baseXp),
                  const SizedBox(height: AppSpacing.lg),
                  profileAsync.when(
                    data: (profile) => _WhyRecommended(
                      explanation: policy.explain(suggestion, profile),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onPressed: creationState.isLoading
                          ? null
                          : () => ref
                                .read(
                                  suggestionCreationControllerProvider(
                                    suggestion.id,
                                  ).notifier,
                                )
                                .create(
                                  suggestion,
                                  title: suggestionTitle(
                                    context,
                                    suggestion.id,
                                  ),
                                  description: suggestionDescription(
                                    context,
                                    suggestion.id,
                                  ),
                                ),
                      icon: creationState.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(l10n.addToMyQuestsButton),
                    ),
                  ),
                  if (creationState.hasError) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.couldntAddQuestLong,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactsCard extends StatelessWidget {
  const _FactsCard({required this.suggestion, required this.baseXp});

  final QuestSuggestion suggestion;
  final int baseXp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FactRow(
            label: l10n.difficultyLabel,
            value: questDifficultyDisplayName(context, suggestion.difficulty),
          ),
          const SizedBox(height: AppSpacing.xs),
          _FactRow(
            label: l10n.estimatedTimeLabel,
            value: l10n.minutesValue(suggestion.estimatedMinutes.toString()),
          ),
          const SizedBox(height: AppSpacing.xs),
          _FactRow(
            label: l10n.repeatsLabel,
            value: repeatabilityDisplayName(context, suggestion.repeatability),
          ),
          const SizedBox(height: AppSpacing.xs),
          _FactRow(
            label: l10n.progressTargetLabel,
            value: suggestion.progressType == ProgressType.binary
                ? l10n.completeOnce
                : suggestion.targetProgress ==
                      suggestion.targetProgress.roundToDouble()
                ? suggestion.targetProgress.toInt().toString()
                : suggestion.targetProgress.toStringAsFixed(1),
          ),
          const SizedBox(height: AppSpacing.xs),
          _FactRow(label: l10n.baseXpLabel, value: '$baseXp XP'),
          if (suggestion.attributeXpWeights.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.attributeAllocationLabel,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final entry in suggestion.attributeXpWeights.entries)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Text(
                      '${attributeDisplayName(context, entry.key)}: '
                      '${entry.value}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// "Why this was recommended" — built directly from the same
/// [SuggestionMatchExplanation] the ranking policy scored with, so this can
/// never claim a match reason that didn't actually affect ranking.
class _WhyRecommended extends StatelessWidget {
  const _WhyRecommended({required this.explanation});

  final SuggestionMatchExplanation explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final reasons = <String>[
      if (explanation.matchesLifeStage) l10n.reasonFitsLifeStage,
      for (final goal in explanation.matchingGoals)
        l10n.reasonMatchesGoal(goalAreaDisplayName(context, goal)),
      if (explanation.fitsAvailableTime) l10n.reasonFitsAvailableTime,
      if (explanation.matchesIntensity) l10n.reasonMatchesIntensity,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.whyRecommendedHeader, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          if (reasons.isEmpty)
            Text(
              l10n.solidStartingPoint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            )
          else
            for (final reason in reasons)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '• $reason',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _SuggestionNotFound extends StatelessWidget {
  const _SuggestionNotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 40,
              color: AppColors.darkTextSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.suggestionNotFound,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
