import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../providers/today_dashboard_providers.dart';

/// Today dashboard §13.2 — a restrained circular indicator standing in for
/// the Daily Score ring, backed by [todayQuestProgressSummaryProvider]'s
/// completion ratio over active quests (not a stored score model; see that
/// provider's doc for why).
class DailyProgressCard extends ConsumerWidget {
  const DailyProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todayQuestProgressSummaryProvider);

    return summaryAsync.when(
      data: (summary) => _DailyProgressContent(summary: summary),
      loading: () => const _DailyProgressSkeleton(),
      error: (error, stackTrace) {
        debugPrint('Today quest progress summary failed to load: $error');
        return _DailyProgressError(
          onRetry: () => ref.invalidate(todayQuestProgressSummaryProvider),
        );
      },
    );
  }
}

class _DailyProgressContent extends StatelessWidget {
  const _DailyProgressContent({required this.summary});

  final TodayQuestProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: summary.completionRatio,
                  strokeWidth: 5,
                  backgroundColor: AppColors.darkSurfaceRaised,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
                Text(
                  '${(summary.completionRatio * 100).round()}%',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  summary.totalActiveQuests == 0
                      ? 'No quests yet'
                      : '${summary.completedToday} of ${summary.totalActiveQuests} quests completed',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyProgressSkeleton extends StatelessWidget {
  const _DailyProgressSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 88,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
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

class _DailyProgressError extends StatelessWidget {
  const _DailyProgressError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Couldn't load today's progress.",
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
