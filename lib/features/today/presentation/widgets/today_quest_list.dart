import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quests/domain/entities/quest.dart';
import '../../../quests/presentation/providers/quest_query_providers.dart';
import '../../../quests/presentation/providers/quest_repository_providers.dart';
import '../../../quests/presentation/widgets/quest_card.dart';

/// Today dashboard §13.4 — a compact list of today's active quests, reusing
/// the existing [QuestCard] (no duplicated quest-list rendering logic; see
/// `QuestsPage._QuestListItem` for the same provider-to-widget bridge this
/// mirrors).
class TodayQuestList extends ConsumerWidget {
  const TodayQuestList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(watchAllQuestsProvider);

    return questsAsync.when(
      data: (quests) {
        final activeQuests = quests
            .where(
              (q) =>
                  q.state != QuestCompletionState.expired &&
                  q.state != QuestCompletionState.converted,
            )
            .toList();
        if (activeQuests.isEmpty) {
          return const _NoQuests();
        }
        return Column(
          children: [
            for (final quest in activeQuests) ...[
              _TodayQuestListItem(quest: quest),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        debugPrint('Today quest list failed to load: $error');
        return _QuestListError(
          onRetry: () => ref.invalidate(watchAllQuestsProvider),
        );
      },
    );
  }
}

class _TodayQuestListItem extends ConsumerWidget {
  const _TodayQuestListItem({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchor = ref.watch(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final progressAsync = ref.watch(
      questProgressForDateProvider(quest.id, anchor),
    );

    return QuestCard(
      quest: quest,
      todayProgress: progressAsync.value,
      onTap: () => context.go(AppRoutes.questDetail(quest.id)),
    );
  }
}

class _NoQuests extends StatelessWidget {
  const _NoQuests();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.noQuestsYet,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary),
    );
  }
}

class _QuestListError extends StatelessWidget {
  const _QuestListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.couldntLoadTodayQuests,
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
    );
  }
}
