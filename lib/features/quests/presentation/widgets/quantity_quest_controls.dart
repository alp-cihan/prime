import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_progress.dart';
import '../providers/quest_progress_controller.dart';
import '../providers/quest_repository_providers.dart';

/// Progress controls for a [ProgressType.quantity] quest: current/target,
/// a progress bar, ±1 buttons, and an optional custom-amount field. All
/// arithmetic happens in [QuestProgressPolicy] via
/// [QuestProgressController] — this widget only renders state and reports
/// intent.
class QuantityQuestControls extends ConsumerStatefulWidget {
  const QuantityQuestControls({
    super.key,
    required this.quest,
    required this.progress,
  });

  final Quest quest;
  final QuestProgress? progress;

  @override
  ConsumerState<QuantityQuestControls> createState() =>
      _QuantityQuestControlsState();
}

class _QuantityQuestControlsState extends ConsumerState<QuantityQuestControls> {
  final _amountController = TextEditingController();
  bool _customAmountValid = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final anchor = ref.watch(
      questOccurrenceAnchorDateProvider(widget.quest.repeatability),
    );
    final controllerState = ref.watch(questProgressControllerProvider);
    final isLoading = controllerState.isLoading;

    final current = widget.progress?.progressValue ?? 0.0;
    final target = widget.quest.targetProgress;
    final ratio = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final atTarget = current >= target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.progressLabel, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_formatValue(current)} / ${_formatValue(target)}',
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
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: isLoading || current <= 0
                  ? null
                  : () => ref
                        .read(questProgressControllerProvider.notifier)
                        .decrement(widget.quest.id, anchor),
              icon: const Icon(Icons.remove),
              tooltip: l10n.decreaseBy1,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            IconButton.filledTonal(
              style: IconButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: isLoading || atTarget
                  ? null
                  : () => ref
                        .read(questProgressControllerProvider.notifier)
                        .increment(widget.quest.id, anchor),
              icon: const Icon(Icons.add, color: Colors.white),
              tooltip: l10n.increaseBy1,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _amountController,
                enabled: !isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.customAmountLabel,
                  isDense: true,
                ),
                onChanged: (value) => setState(
                  () => _customAmountValid =
                      double.tryParse(value.trim()) != null,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: isLoading || !_customAmountValid
                  ? null
                  : _submitCustomAmount,
              child: Text(l10n.addButton),
            ),
          ],
        ),
      ],
    );
  }

  void _submitCustomAmount() {
    final parsed = double.tryParse(_amountController.text.trim());
    if (parsed == null) return;
    final anchor = ref.read(
      questOccurrenceAnchorDateProvider(widget.quest.repeatability),
    );
    ref
        .read(questProgressControllerProvider.notifier)
        .addAmount(widget.quest.id, anchor, parsed);
    _amountController.clear();
    setState(() => _customAmountValid = false);
  }

  String _formatValue(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}
