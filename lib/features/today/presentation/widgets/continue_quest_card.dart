import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quests/domain/entities/quest.dart';
import '../../../quests/domain/entities/quest_progress.dart';
import '../../../quests/presentation/providers/quest_query_providers.dart';
import '../../../quests/presentation/providers/quest_repository_providers.dart';
import '../providers/today_dashboard_providers.dart';

/// Phase 18 (Today 2.0) — a compact nudge back to a *second* quest already
/// in progress today (e.g. "12 / 20", "15 / 30 min"), distinct from the
/// hero Today's Mission card above. Entirely self-governing: renders nothing
/// — including its own top spacing — whenever [continueQuestProvider] has no
/// candidate (loading, error, or genuinely none), so [TodayPage] never has
/// to know whether this section is present. See that provider's own doc for
/// the exact selection rule.
class ContinueQuestCard extends ConsumerWidget {
  const ContinueQuestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questAsync = ref.watch(continueQuestProvider);

    return questAsync.when(
      data: (quest) => quest == null
          ? const SizedBox.shrink()
          : _ContinueContent(quest: quest),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) {
        // Deliberately silent in the UI — Continue is a secondary nudge, not
        // essential information; a failure here should never intrude on an
        // otherwise-working dashboard the way the hero/Daily Momentum
        // errors do. Still logged for diagnosis.
        debugPrint('Continue quest failed to load: $error');
        return const SizedBox.shrink();
      },
    );
  }
}

class _ContinueContent extends ConsumerWidget {
  const _ContinueContent({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final anchor = ref.watch(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final progressAsync = ref.watch(
      questProgressForDateProvider(quest.id, anchor),
    );
    final progress = progressAsync.value;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: GradientSurfaceCard(
        onTap: () => context.go(AppRoutes.questDetail(quest.id)),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: QuestVisual(
                seed: quest.visualKey ?? quest.id,
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
                    l10n.continueLabel.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quest.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _ContinueProgress(quest: quest, progress: progress),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, color: AppColors.darkTextSecondary),
          ],
        ),
      ),
    );
  }
}

class _ContinueProgress extends StatelessWidget {
  const _ContinueProgress({required this.quest, required this.progress});

  final Quest quest;
  final QuestProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = progress?.progressValue ?? 0.0;
    final target = quest.targetProgress;
    final ratio = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final unit = quest.progressType == ProgressType.duration
        ? AppLocalizations.of(context)!.minutesUnit
        : '';

    return Row(
      children: [
        Text(
          '${_formatValue(current)}$unit / ${_formatValue(target)}$unit',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: AppColors.darkSurfaceRaised,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }

  String _formatValue(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}
