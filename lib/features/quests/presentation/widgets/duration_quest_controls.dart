import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_progress.dart';
import '../providers/quest_progress_controller.dart';
import '../providers/quest_repository_providers.dart';

/// Progress controls for a [ProgressType.duration] quest: current/target in
/// minutes (this phase's fixed unit — see [QuestProgressPolicy]'s doc), a
/// progress bar, and quick-add buttons. No live stopwatch — every add is a
/// single explicit tap, per Phase 8 scope.
class DurationQuestControls extends ConsumerWidget {
  const DurationQuestControls({
    super.key,
    required this.quest,
    required this.progress,
  });

  final Quest quest;
  final QuestProgress? progress;

  static const _quickAddMinutes = [5.0, 10.0, 15.0];
  static const _decrementMinutes = 5.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final anchor = ref.watch(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final controllerState = ref.watch(questProgressControllerProvider);
    final isLoading = controllerState.isLoading;

    final current = progress?.progressValue ?? 0.0;
    final target = quest.targetProgress;
    final ratio = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final atTarget = current >= target;
    final notifier = ref.read(questProgressControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.progressLabel, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${current.toInt()} / ${target.toInt()}${l10n.minutesUnit}',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              '${(ratio * 100).round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.darkSurfaceRaised,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: isLoading || current <= 0
                  ? null
                  : () => notifier.decrement(
                      quest.id,
                      anchor,
                      amount: _decrementMinutes,
                    ),
              icon: const Icon(Icons.remove),
              label: Text(l10n.decrementMinutes(_decrementMinutes.toInt())),
            ),
            for (final minutes in _quickAddMinutes)
              FilledButton.tonalIcon(
                onPressed: isLoading || atTarget
                    ? null
                    : () =>
                          notifier.increment(quest.id, anchor, amount: minutes),
                icon: const Icon(Icons.add),
                label: Text(l10n.minutesValue(minutes.toInt().toString())),
              ),
          ],
        ),
        if (isLoading) ...[
          const SizedBox(height: AppSpacing.sm),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ],
    );
  }
}
