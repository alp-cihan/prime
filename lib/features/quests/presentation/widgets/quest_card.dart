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
    final completedToday = todayProgress?.isComplete ?? false;

    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quest.title, style: theme.textTheme.titleMedium),
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
                        _Chip(
                          label: questDifficultyDisplayName(quest.difficulty),
                        ),
                        _Chip(label: '$baseXp XP'),
                        if (primaryAttribute != null)
                          _Chip(label: attributeDisplayName(primaryAttribute)),
                      ],
                    ),
                    if (completedToday) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Completed today',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
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
        ),
      ),
    );
  }
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
