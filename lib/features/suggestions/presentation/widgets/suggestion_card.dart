import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../application/models/create_quest_from_suggestion_outcome.dart';
import '../../domain/entities/quest_suggestion.dart';
import '../providers/suggestion_creation_controller.dart';

/// Image-forward suggestion card for the Suggestions page's single-column
/// list — reuses the Phase 15 visual system (`GradientSurfaceCard`,
/// `QuestVisual`) so a suggestion reads as inspirational, not like a
/// settings row. The photo is the card's focal point and text is
/// deliberately secondary: [_photoHeight] is fixed, while the text block
/// below sizes itself to its content (title/description each capped at 2
/// lines, never a fixed height) — with that cap, the two together land
/// close to a 55/45 photo-to-text split for typical two-line content,
/// without ever risking the overflow a hard-coded total height would.
class SuggestionCard extends ConsumerWidget {
  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.onTap,
    required this.onAdded,
  });

  final QuestSuggestion suggestion;
  final VoidCallback onTap;

  /// Called once, the first time this card's add action reaches a terminal
  /// (non-error) outcome — the caller shows a SnackBar/opens the quest.
  final ValueChanged<CreateQuestFromSuggestionOutcome> onAdded;

  static const _photoHeight = 210.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final baseXp = suggestion.attributeXpWeights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    ref.listen<AsyncValue<CreateQuestFromSuggestionOutcome?>>(
      suggestionCreationControllerProvider(suggestion.id),
      (previous, next) {
        final outcome = next.value;
        if (next.hasValue && outcome != null) onAdded(outcome);
      },
    );

    final creationState = ref.watch(
      suggestionCreationControllerProvider(suggestion.id),
    );

    return GradientSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestVisual(
            seed: suggestion.visualKey,
            icon: attributeIcon(suggestion.primaryAttribute),
            height: _photoHeight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  suggestion.title,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  suggestion.description,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _MetaChip(label: '${suggestion.estimatedMinutes} min'),
                    _MetaChip(
                      label: questDifficultyDisplayName(suggestion.difficulty),
                    ),
                    _MetaChip(label: '$baseXp XP'),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: creationState.isLoading
                        ? null
                        : () => ref
                              .read(
                                suggestionCreationControllerProvider(
                                  suggestion.id,
                                ).notifier,
                              )
                              .create(suggestion),
                    icon: creationState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add, size: 18),
                    label: const Text('Add Quest'),
                  ),
                ),
                if (creationState.hasError) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Couldn't add this quest. Try again.",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
