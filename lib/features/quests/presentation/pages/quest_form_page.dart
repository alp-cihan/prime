import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/quest_query_providers.dart';
import '../widgets/quest_form.dart';

/// Create/edit quest route — `/quests/new` ([questId] null) and
/// `/quests/:questId/edit` ([questId] set). In edit mode this page owns
/// loading [questByIdProvider] first; [QuestForm] is only ever constructed
/// once the quest has resolved, so it never has to represent a
/// still-loading quest itself, and a submit can never race an unloaded
/// record.
class QuestFormPage extends ConsumerWidget {
  const QuestFormPage({super.key, this.questId});

  /// Null in create mode; the quest id being edited in edit mode.
  final String? questId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = questId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.newQuestTitle)),
        body: const QuestForm(),
      );
    }

    final questAsync = ref.watch(questByIdProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editQuestTitle)),
      body: questAsync.when(
        data: (quest) {
          if (quest == null) return const _QuestNotFound();
          return QuestForm(questId: id, initialQuest: quest);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint('Quest form failed to load quest $id: $error');
          return _LoadError(
            onRetry: () => ref.invalidate(questByIdProvider(id)),
          );
        },
      ),
    );
  }
}

class _QuestNotFound extends StatelessWidget {
  const _QuestNotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 40,
              color: AppColors.darkTextSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.questNotFound,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

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
              l10n.couldntLoadQuest,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.questLoadErrorBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
