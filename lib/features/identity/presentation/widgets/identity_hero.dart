import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/identity_snapshot.dart';

/// Identity 2.0 hero — replaces the old accounting-style profile summary
/// with the page's single dominant element: "who am I becoming?" answered
/// through the level, lifetime XP, and one data-driven growth line.
///
/// Future avatar readiness: the [ProgressRing] below is the hero's visual
/// centerpiece today (an abstract ring + the level numeral). When a visual
/// character/avatar system is built, that avatar is intended to occupy this
/// same centerpiece slot — replacing or wrapping the ring — without another
/// full-page redesign. No avatar entities, assets, or state are introduced
/// here; this is presentation-only preparation.
class IdentityHero extends StatelessWidget {
  const IdentityHero({super.key, required this.snapshot});

  final IdentitySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progress = snapshot.progressRatio.clamp(0.0, 1.0);

    return GradientSurfaceCard(
      gradient: AppGradients.hero,
      borderRadius: 24,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.youTitle.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.darkTextSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Future avatar centerpiece slot — see class doc.
              ProgressRing(
                progress: progress,
                size: 88,
                strokeWidth: 7,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${snapshot.currentLevel}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    Text(
                      l10n.levelLabel.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.darkTextSecondary,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.playerXpTotal(formatXp(snapshot.lifetimeXp)),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.playerXpToNextLevel(
                        snapshot.xpIntoCurrentLevel,
                        snapshot.xpNeededForNextLevel,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _identityMessage(context, l10n, snapshot),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkTextSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _identityMessage(
  BuildContext context,
  AppLocalizations l10n,
  IdentitySnapshot snapshot,
) {
  final strongest = snapshot.strongestAttribute;
  if (strongest == null) return l10n.identityNoActivityYet;
  return l10n.identityCurrentlyStrongest(
    attributeDisplayName(context, strongest),
  );
}
