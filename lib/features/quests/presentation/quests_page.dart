import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/quest.dart';
import 'providers/quest_query_providers.dart';
import 'providers/quest_repository_providers.dart';
import 'widgets/quest_card.dart';

class QuestsPage extends ConsumerWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(watchAllQuestsProvider);
    final l10n = AppLocalizations.of(context)!;

    return PrimePageScaffold(
      title: l10n.questsTitle,
      actions: [
        IconButton(
          onPressed: () => context.push(AppRoutes.suggestions),
          icon: const Icon(Icons.auto_awesome_outlined),
          tooltip: l10n.suggestionsTooltip,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.questNew),
        tooltip: l10n.createQuestTooltip,
        child: const Icon(Icons.add),
      ),
      body: questsAsync.when(
        data: (quests) {
          if (quests.isEmpty) {
            return const _EmptyQuests();
          }
          return ListView.separated(
            itemCount: quests.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) =>
                _QuestListItem(quest: quests[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _QuestsError(error: error),
      ),
    );
  }
}

/// Bridges Riverpod to the pure-presentational [QuestCard] — the one place
/// per list item that reads a provider (today's progress for that specific
/// quest), so `QuestCard` itself stays a dumb widget with no provider reads.
class _QuestListItem extends ConsumerWidget {
  const _QuestListItem({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayUtcProvider);
    final progressAsync = ref.watch(
      questProgressForDateProvider(quest.id, today),
    );

    return QuestCard(
      quest: quest,
      todayProgress: progressAsync.value,
      onTap: () => context.go(AppRoutes.questDetail(quest.id)),
    );
  }
}

class _EmptyQuests extends StatelessWidget {
  const _EmptyQuests();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.noQuestsYet,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.questNew),
              icon: const Icon(Icons.add),
              label: Text(l10n.createQuestLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.suggestions),
              icon: const Icon(Icons.auto_awesome_outlined),
              label: Text(l10n.browseSuggestions),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestsError extends ConsumerWidget {
  const _QuestsError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A raw provider error (e.g. Riverpod's ProviderException) can embed its
    // entire stack trace in toString() — rendering that directly caused a
    // real, reproducible layout overflow. Show a short, friendly message
    // and keep the real error out of the widget tree entirely; it's still
    // visible via debugPrint for debugging.
    debugPrint('Quest list failed to load: $error');
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.couldntLoadQuests,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.questsLoadErrorBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => ref.invalidate(watchAllQuestsProvider),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
