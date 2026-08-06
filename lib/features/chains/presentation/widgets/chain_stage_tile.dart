import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quests/presentation/providers/quest_query_providers.dart';
import '../../domain/entities/chain_stage.dart';

/// One row in the Chain Detail page's stage list — the quest's title (via
/// `questByIdProvider`, the same cross-feature lookup `ChainCard` uses) plus
/// a status glyph, with the current stage visually highlighted. Never
/// computes stage status itself — [stage].status already came from
/// `ChainProgressPolicy`.
class ChainStageTile extends ConsumerWidget {
  const ChainStageTile({
    super.key,
    required this.stage,
    required this.isCurrent,
  });

  final ChainStage stage;
  final bool isCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final questAsync = ref.watch(questByIdProvider(stage.questId));
    final locked = stage.status == ChainStageStatus.locked;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? AppColors.accent : AppColors.darkBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(_iconFor(stage.status), color: _colorFor(stage.status)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locked
                      ? l10n.chainStageLockedTitle
                      : (questAsync.value?.title ??
                            l10n.chainStageFallbackTitle(stage.index + 1)),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: locked ? AppColors.darkTextSecondary : null,
                  ),
                ),
                Text(
                  _labelFor(l10n, stage.status),
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

  IconData _iconFor(ChainStageStatus status) => switch (status) {
    ChainStageStatus.completed => Icons.check_circle,
    ChainStageStatus.unlocked => Icons.play_circle_outline,
    ChainStageStatus.locked => Icons.lock_outline,
  };

  Color _colorFor(ChainStageStatus status) => switch (status) {
    ChainStageStatus.completed => AppColors.accent,
    ChainStageStatus.unlocked => AppColors.accent,
    ChainStageStatus.locked => AppColors.darkTextSecondary,
  };

  /// The title already reads "Locked" for a locked stage — this subtitle
  /// stays distinct rather than repeating that word on the same tile.
  String _labelFor(AppLocalizations l10n, ChainStageStatus status) =>
      switch (status) {
        ChainStageStatus.completed => l10n.chainStageCompleted,
        ChainStageStatus.unlocked => l10n.chainStageInProgress,
        ChainStageStatus.locked => l10n.chainStageLockedSubtitle,
      };
}
