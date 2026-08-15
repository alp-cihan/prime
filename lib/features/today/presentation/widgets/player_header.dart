import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
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
String _motivationalLine(AppLocalizations l10n, int level) {
  final lines = [
    l10n.motivationalLine1,
    l10n.motivationalLine2,
    l10n.motivationalLine3,
    l10n.motivationalLine4,
    l10n.motivationalLine5,
  ];
  return lines[level % lines.length];
}

String _greeting(AppLocalizations l10n, DateTime now) {
  if (now.hour < 5) return l10n.greetingNight;
  if (now.hour < 12) return l10n.greetingMorning;
  if (now.hour < 18) return l10n.greetingAfternoon;
  return l10n.greetingEvening;
}

class _PlayerHeaderContent extends StatelessWidget {
  const _PlayerHeaderContent({required this.summary});

  final PlayerLevelSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progress = summary.progressRatio.clamp(0.0, 1.0);

    // Phase 18 (Today 2.0): deliberately compact — the hero Today's Mission
    // card below is the screen's dominant element, so this trims padding/
    // ring size/type scale versus the original v1 hero-style header without
    // dropping any of the required content (greeting, level, lifetime XP,
    // progress, one motivational line).
    return GradientSurfaceCard(
      gradient: AppGradients.hero,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(l10n, DateTime.now()),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.playerLevelLabel(summary.currentLevel),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.playerXpTotal(formatXp(summary.totalXp)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    Text(
                      l10n.playerXpToNextLevel(
                        summary.xpIntoCurrentLevel,
                        summary.xpNeededForNextLevel,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ProgressRing(
                progress: progress,
                size: 48,
                strokeWidth: 5,
                child: Text(
                  l10n.percentValue((progress * 100).round()),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _motivationalLine(l10n, summary.currentLevel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
      height: 128,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
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
              AppLocalizations.of(context)!.couldntLoadLevel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}
