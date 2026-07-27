import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../xp_ledger/presentation/models/player_level_summary.dart';
import '../../../xp_ledger/presentation/providers/player_level_providers.dart';

/// Today dashboard §13.1 Player Header — compact, single-row-feeling card:
/// current level, total XP, and a thin progress bar toward the next level.
/// Section-scoped loading/error so a slow/failed player-level read never
/// blanks the rest of the dashboard.
class PlayerHeader extends ConsumerWidget {
  const PlayerHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(playerLevelSummaryProvider);

    return summaryAsync.when(
      data: (summary) => _PlayerHeaderContent(summary: summary),
      loading: () => const _PlayerHeaderSkeleton(),
      error: (error, stackTrace) {
        debugPrint('Player level summary failed to load: $error');
        return _PlayerHeaderError(
          onRetry: () => ref.invalidate(playerLevelSummaryProvider),
        );
      },
    );
  }
}

class _PlayerHeaderContent extends StatelessWidget {
  const _PlayerHeaderContent({required this.summary});

  final PlayerLevelSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = summary.progressRatio.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Level ${summary.currentLevel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(width: AppSpacing.sm),
              // Lifetime XP has no upper bound — this side must be allowed
              // to shrink/truncate rather than overflow a narrow screen.
              Expanded(
                child: Text(
                  '${summary.totalXp} XP total',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.darkSurfaceRaised,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${summary.xpIntoCurrentLevel} / ${summary.xpNeededForNextLevel} XP to next level',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerHeaderSkeleton extends StatelessWidget {
  const _PlayerHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 84,
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

class _PlayerHeaderError extends StatelessWidget {
  const _PlayerHeaderError({required this.onRetry});

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
              "Couldn't load your level.",
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
