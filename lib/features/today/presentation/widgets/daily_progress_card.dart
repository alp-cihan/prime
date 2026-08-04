import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../providers/today_dashboard_providers.dart';

/// Today dashboard §13.2 "Daily momentum" — a compact, energetic radial
/// indicator standing in for the Daily Score ring, backed by
/// [todayQuestProgressSummaryProvider]'s completion ratio over active
/// quests (not a stored score model; see that provider's doc for why),
/// paired with [todayXpTotalProvider]'s XP-earned-today figure so momentum
/// and reward read as one composition.
class DailyProgressCard extends ConsumerWidget {
  const DailyProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todayQuestProgressSummaryProvider);
    final xpAsync = ref.watch(todayXpTotalProvider);

    if (summaryAsync.isLoading || xpAsync.isLoading) {
      return const _DailyProgressSkeleton();
    }
    if (summaryAsync.hasError) {
      debugPrint(
        "Today's quest progress summary failed to load: "
        '${summaryAsync.error}',
      );
      return _DailyProgressError(
        onRetry: () => ref.invalidate(todayQuestProgressSummaryProvider),
      );
    }
    if (xpAsync.hasError) {
      debugPrint("Today's XP total failed to load: ${xpAsync.error}");
      return _DailyProgressError(
        onRetry: () => ref.invalidate(todayXpTotalProvider),
      );
    }

    return _DailyProgressContent(
      summary: summaryAsync.value!,
      todayXp: xpAsync.value ?? 0,
    );
  }
}

class _DailyProgressContent extends StatelessWidget {
  const _DailyProgressContent({required this.summary, required this.todayXp});

  final TodayQuestProgressSummary summary;
  final int todayXp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientSurfaceCard(
      child: Row(
        children: [
          ProgressRing(
            progress: summary.completionRatio,
            size: 56,
            strokeWidth: 5,
            child: Text(
              '${(summary.completionRatio * 100).round()}%',
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily momentum', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  summary.totalActiveQuests == 0
                      ? 'No quests yet'
                      : '${summary.completedToday} of ${summary.totalActiveQuests} quests completed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${formatXp(todayXp)} XP today',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
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
      height: 96,
      padding: const EdgeInsets.all(AppSpacing.md),
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
        borderRadius: BorderRadius.circular(20),
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
