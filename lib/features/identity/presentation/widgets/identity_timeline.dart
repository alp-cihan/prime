import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../achievements/presentation/achievement_icon.dart';
import '../../../achievements/presentation/achievement_localization.dart';
import '../../../chains/presentation/chain_icon.dart';
import '../../domain/entities/identity_milestone.dart';

/// Recent-milestones timeline — newest first, one row per
/// [IdentityMilestone]. Reuses the achievements/chains features' own icon
/// mappings (Phase 12: "Use existing icon system where possible") rather
/// than inventing a third one.
class IdentityTimeline extends StatelessWidget {
  const IdentityTimeline({super.key, required this.milestones});

  final List<IdentityMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recentMilestonesHeader, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (milestones.isEmpty)
          Text(
            l10n.noMilestonesYet,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          )
        else
          for (final milestone in milestones) ...[
            _MilestoneTile(milestone: milestone),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({required this.milestone});

  final IdentityMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_iconFor(milestone), color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedTitle(context, milestone),
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatShortDate(milestone.occurredAt),
                  style: theme.textTheme.labelSmall?.copyWith(
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

  /// Built from [milestone.level]/[milestone.refId] (not [milestone.title],
  /// which `IdentityService` — a pure-Dart application service with no
  /// access to `AppLocalizations` — always pre-builds in English; see
  /// `IdentityMilestone`'s own doc for why both exist).
  String _localizedTitle(BuildContext context, IdentityMilestone milestone) {
    final l10n = AppLocalizations.of(context)!;
    switch (milestone.type) {
      case IdentityMilestoneType.levelReached:
        return l10n.milestoneReachedLevel(milestone.level!);
      case IdentityMilestoneType.achievementUnlocked:
        return l10n.milestoneUnlockedAchievement(
          achievementTitle(context, milestone.refId!),
        );
      case IdentityMilestoneType.chainCompleted:
        return l10n.milestoneCompletedChain(milestone.refId!);
    }
  }

  IconData _iconFor(IdentityMilestone milestone) {
    switch (milestone.type) {
      case IdentityMilestoneType.levelReached:
        return Icons.star_outline;
      case IdentityMilestoneType.achievementUnlocked:
        return achievementIconForKey(milestone.iconKey);
      case IdentityMilestoneType.chainCompleted:
        return chainIconForKey(milestone.iconKey);
    }
  }
}
