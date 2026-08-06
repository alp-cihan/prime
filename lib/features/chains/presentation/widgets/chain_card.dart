import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quests/presentation/providers/quest_query_providers.dart';
import '../chain_icon.dart';
import '../models/chain_with_progress.dart';

/// The Chains page's summary card — title, description, progress bar,
/// current quest, and completion %. A hidden, not-yet-started chain shows
/// only "Hidden Chain" (mirrors `AchievementsPage`'s hidden-achievement
/// masking), revealing its real title/description the moment it starts.
class ChainCard extends ConsumerWidget {
  const ChainCard({super.key, required this.entry, required this.onTap});

  final ChainWithProgress entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final chain = entry.chain;
    final hidden = chain.hiddenUntilStarted && !entry.hasStarted;
    final currentStage = entry.currentStage;
    final currentQuestAsync = currentStage == null
        ? null
        : ref.watch(questByIdProvider(currentStage.questId));

    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hidden
                        ? Icons.help_outline
                        : chainIconForKey(chain.iconKey),
                    color: entry.isCompleted
                        ? AppColors.accent
                        : AppColors.darkTextSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      hidden ? l10n.hiddenChainTitle : chain.title,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    l10n.percentValue((entry.completionPercent * 100).round()),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                hidden ? l10n.hiddenChainBody : chain.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: entry.completionPercent,
                  minHeight: 6,
                  backgroundColor: AppColors.darkSurfaceRaised,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
              if (!hidden && currentQuestAsync != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.chainCurrentQuestLabel(
                    currentQuestAsync.value?.title ?? '…',
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
