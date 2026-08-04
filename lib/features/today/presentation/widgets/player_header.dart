import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../xp_ledger/presentation/models/player_level_summary.dart';
import '../../../xp_ledger/presentation/providers/player_level_providers.dart';

/// Today dashboard §13.1 Player Header — now a cinematic hero card: a
/// time-of-day greeting, current level, lifetime XP, a progress ring toward
/// the next level, and a short motivational line. Section-scoped
/// loading/error so a slow/failed player-level read never blanks the rest
/// of the dashboard.
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

/// Deterministic, presentation-only line — no new provider or persisted
/// state; a small fixed rotation keyed off the current level keeps it
/// stable within a session without inventing a "motivation" domain concept.
const _motivationalLines = [
  'Small consistent steps compound.',
  'Momentum is built one quest at a time.',
  'Discipline today, progress tomorrow.',
  'Show up — the rest follows.',
  'Every rep counts toward the next level.',
];

String _motivationalLine(int level) =>
    _motivationalLines[level % _motivationalLines.length];

String _greeting(DateTime now) {
  if (now.hour < 5) return 'Good night';
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 18) return 'Good afternoon';
  return 'Good evening';
}

class _PlayerHeaderContent extends StatelessWidget {
  const _PlayerHeaderContent({required this.summary});

  final PlayerLevelSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = summary.progressRatio.clamp(0.0, 1.0);

    return GradientSurfaceCard(
      gradient: AppGradients.hero,
      borderRadius: 24,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(DateTime.now()),
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${summary.currentLevel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${formatXp(summary.totalXp)} XP total',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              ProgressRing(
                progress: progress,
                size: 64,
                strokeWidth: 6,
                child: Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${summary.xpIntoCurrentLevel} / ${summary.xpNeededForNextLevel} XP to next level',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _motivationalLine(summary.currentLevel),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.darkTextSecondary,
              fontStyle: FontStyle.italic,
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
      height: 168,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(24),
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
