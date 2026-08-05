import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';
import '../../../../core/router/app_routes.dart';
import '../../../quests/domain/entities/quest.dart';
import '../../../quests/domain/entities/quest_progress.dart';
import '../../../quests/presentation/providers/quest_query_providers.dart';
import '../../../quests/presentation/providers/quest_repository_providers.dart';
import '../providers/today_dashboard_providers.dart';

/// Today dashboard §13.3 Main Quest card — the one system-selected priority
/// quest ([featuredQuestProvider]), now image-forward via [QuestVisual].
/// Tapping navigates to the existing [QuestDetailPage]; completion itself
/// always happens there, never from this card (Phase 6 scope explicitly
/// excludes completing from the dashboard).
class FeaturedQuestCard extends ConsumerWidget {
  const FeaturedQuestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questAsync = ref.watch(featuredQuestProvider);

    return questAsync.when(
      data: (quest) => quest == null
          ? const _NoFeaturedQuest()
          : _FeaturedQuestContent(quest: quest),
      loading: () => const _FeaturedQuestSkeleton(),
      error: (error, stackTrace) {
        debugPrint('Featured quest failed to load: $error');
        return _FeaturedQuestError(
          onRetry: () => ref.invalidate(featuredQuestProvider),
        );
      },
    );
  }
}

class _FeaturedQuestContent extends ConsumerWidget {
  const _FeaturedQuestContent({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final anchor = ref.watch(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final progressAsync = ref.watch(
      questProgressForDateProvider(quest.id, anchor),
    );
    final progress = progressAsync.value;
    final completedToday = progress?.isComplete ?? false;
    final baseXp = quest.attributeXpWeights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final primaryAttribute = _primaryAttribute(quest.attributeXpWeights);

    return GradientSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      onTap: () => context.go(AppRoutes.questDetail(quest.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestVisual(
            seed: quest.id,
            icon: primaryAttribute == null
                ? null
                : attributeIcon(primaryAttribute),
            height: 140,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MAIN QUEST',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  quest.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _Chip(label: questDifficultyDisplayName(quest.difficulty)),
                    _Chip(label: '${formatXp(baseXp)} XP'),
                    if (completedToday) const _Chip(label: 'Completed today'),
                  ],
                ),
                if (quest.progressType != ProgressType.binary) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _FeaturedQuestProgress(quest: quest, progress: progress),
                ],
                const SizedBox(height: AppSpacing.md),
                _FeaturedQuestCta(label: _ctaLabel(quest, completedToday)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _ctaLabel(Quest quest, bool completedToday) {
    if (completedToday) return 'View';
    switch (quest.progressType) {
      case ProgressType.binary:
        return 'Complete';
      case ProgressType.quantity:
        return 'Add Progress';
      case ProgressType.duration:
        return 'Continue';
    }
  }
}

AttributeType? _primaryAttribute(Map<AttributeType, int> weights) {
  if (weights.isEmpty) return null;
  var best = weights.entries.first;
  for (final entry in weights.entries.skip(1)) {
    if (entry.value > best.value) best = entry;
  }
  return best.key;
}

/// The card's whole surface already navigates via [GradientSurfaceCard]'s
/// `onTap` — this is a purely visual affordance (a filled gradient pill),
/// not a second tap target, so it stays a `Container`, not a `Button`.
class _FeaturedQuestCta extends StatelessWidget {
  const _FeaturedQuestCta({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: AppGradients.cta,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppColors.darkTextPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact quantity/duration readout — mirrors `QuestCard`'s
/// `_CompactProgress`, kept local since it's the only other place Today
/// shows a featured quest's live progress.
class _FeaturedQuestProgress extends StatelessWidget {
  const _FeaturedQuestProgress({required this.quest, required this.progress});

  final Quest quest;
  final QuestProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = progress?.progressValue ?? 0.0;
    final target = quest.targetProgress;
    final ratio = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final unit = quest.progressType == ProgressType.duration ? ' min' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_formatValue(current)}$unit / ${_formatValue(target)}$unit',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 4,
            backgroundColor: AppColors.darkSurfaceRaised,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      ],
    );
  }

  String _formatValue(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

class _NoFeaturedQuest extends StatelessWidget {
  const _NoFeaturedQuest();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No quests yet. Quests you create will show up here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.suggestions),
            icon: const Icon(Icons.auto_awesome_outlined, size: 18),
            label: const Text('Browse Suggestions'),
          ),
        ],
      ),
    );
  }
}

class _FeaturedQuestSkeleton extends StatelessWidget {
  const _FeaturedQuestSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 236,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _FeaturedQuestError extends StatelessWidget {
  const _FeaturedQuestError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Couldn't load your main quest.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
