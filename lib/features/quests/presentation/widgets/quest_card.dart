import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_progress.dart';

/// Pure presentational quest-list tile — everything it shows comes from its
/// constructor parameters. No provider reads happen here; the caller
/// (`QuestsPage`) is responsible for resolving [todayProgress].
class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.quest,
    required this.todayProgress,
    required this.onTap,
  });

  final Quest quest;
  final QuestProgress? todayProgress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseXp = quest.attributeXpWeights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final primaryAttribute = _primaryAttribute(quest.attributeXpWeights);

    return GradientSurfaceCard(
      borderRadius: 16,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: QuestVisual(
              seed: quest.id,
              icon: primaryAttribute == null
                  ? null
                  : attributeIcon(primaryAttribute),
              height: 48,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                if (quest.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    quest.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _Chip(label: questDifficultyDisplayName(quest.difficulty)),
                    _Chip(label: '${formatXp(baseXp)} XP'),
                    if (primaryAttribute != null)
                      _Chip(label: attributeDisplayName(primaryAttribute)),
                  ],
                ),
                _CompactProgress(quest: quest, todayProgress: todayProgress),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Icon(
              Icons.chevron_right,
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact, non-interactive progress readout for the quest list/Today rows
/// — full increment/decrement controls only ever live on the detail page
/// (Phase 8 scope). Binary shows the existing "Completed today" text (or
/// nothing); quantity/duration show a "current / target" line plus a thin
/// progress bar.
class _CompactProgress extends StatelessWidget {
  const _CompactProgress({required this.quest, required this.todayProgress});

  final Quest quest;
  final QuestProgress? todayProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (quest.progressType == ProgressType.binary) {
      final completedToday = todayProgress?.isComplete ?? false;
      if (!completedToday) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          'Completed today',
          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.accent),
        ),
      );
    }

    final current = todayProgress?.progressValue ?? 0.0;
    final target = quest.targetProgress;
    final ratio = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final unit = quest.progressType == ProgressType.duration ? ' min' : '';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
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
      ),
    );
  }

  String _formatValue(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

AttributeType? _primaryAttribute(Map<AttributeType, int> weights) {
  if (weights.isEmpty) return null;
  var best = weights.entries.first;
  for (final entry in weights.entries.skip(1)) {
    if (entry.value > best.value) best = entry;
  }
  return best.key;
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
