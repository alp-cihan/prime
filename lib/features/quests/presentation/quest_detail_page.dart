import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/domain/failure.dart';
import '../../../core/router/app_routes.dart';
import '../../xp_ledger/presentation/providers/xp_ledger_providers.dart';
import '../application/models/complete_quest_command.dart';
import '../application/models/complete_quest_result.dart';
import '../application/models/update_quest_progress_result.dart';
import '../domain/entities/quest.dart';
import '../domain/entities/quest_progress.dart';
import 'providers/complete_quest_controller.dart';
import 'providers/delete_quest_controller.dart';
import 'providers/quest_progress_controller.dart';
import 'providers/quest_query_providers.dart';
import 'providers/quest_repository_providers.dart';
import 'widgets/complete_quest_button.dart';
import 'widgets/duration_quest_controls.dart';
import 'widgets/quantity_quest_controls.dart';
import 'widgets/quest_progress_summary.dart';

/// Quest detail screen — `/quests/:questId`, pushed onto the quests branch's
/// own navigation stack (see app_router.dart), so the bottom nav stays
/// visible and back navigation returns to the list without losing its
/// scroll position or the other tabs' state.
class QuestDetailPage extends ConsumerStatefulWidget {
  const QuestDetailPage({super.key, required this.questId});

  final String questId;

  @override
  ConsumerState<QuestDetailPage> createState() => _QuestDetailPageState();
}

class _QuestDetailPageState extends ConsumerState<QuestDetailPage> {
  @override
  void initState() {
    super.initState();
    // `deleteQuestControllerProvider`/`questProgressControllerProvider` are
    // single shared, keepAlive controllers — without this, a previous
    // quest's failed deletion (or a stale quantity/duration mutation
    // result) would otherwise still be sitting there the first time *this*
    // quest's detail page reads it.
    Future.microtask(() {
      ref.read(deleteQuestControllerProvider.notifier).reset();
      ref.read(questProgressControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final questAsync = ref.watch(questByIdProvider(widget.questId));
    final deleteState = ref.watch(deleteQuestControllerProvider);

    // Fires only on an actual state transition (Riverpod dedupes the
    // underlying subscription per element), never on an unrelated rebuild —
    // this is what keeps the success confirmation from appearing twice.
    ref.listen<AsyncValue<CompleteQuestResult?>>(
      completeQuestControllerProvider,
      (previous, next) {
        final result = next.value;
        if (next.hasValue && result != null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Quest completed — +${result.totalXpAwarded} XP'),
            ),
          );
        } else if (next.hasError) {
          // Preserve the underlying Failure for debugging even though the UI
          // only shows a friendly message (built inline below).
          debugPrint('CompleteQuest failed: ${next.error}');
        }
      },
    );

    // Same shape as the completeQuestControllerProvider listener above, for
    // the quantity/duration mutation path — fires the same-format success
    // message only when *this* mutation was the one that newly completed
    // the quest (see UpdateQuestProgressUseCase's doc for that guarantee),
    // so a plain increment/decrement that doesn't reach the target never
    // shows it.
    ref.listen<AsyncValue<UpdateQuestProgressResult?>>(
      questProgressControllerProvider,
      (previous, next) {
        final result = next.value;
        if (next.hasValue &&
            result != null &&
            result.completed &&
            result.completionResult != null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Quest completed — '
                '+${result.completionResult!.totalXpAwarded} XP',
              ),
            ),
          );
        } else if (next.hasError) {
          debugPrint('Quest progress update failed: ${next.error}');
        }
      },
    );

    ref.listen<AsyncValue<bool>>(deleteQuestControllerProvider, (
      previous,
      next,
    ) {
      if (next.hasValue && next.value == true) {
        if (!context.mounted) return;
        // Explicit target rather than a pop — correct regardless of how
        // this detail page was reached (e.g. from the Today dashboard).
        context.go(AppRoutes.quests);
        ref.read(deleteQuestControllerProvider.notifier).reset();
      } else if (next.hasError) {
        debugPrint('Quest delete failed: ${next.error}');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          questAsync.value?.title ?? 'Quest',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: deleteState.isLoading
                ? null
                : () => context.go(AppRoutes.questEdit(widget.questId)),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Quest',
          ),
          IconButton(
            onPressed: deleteState.isLoading
                ? null
                : () => _confirmDelete(context, questAsync.value),
            icon: deleteState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            tooltip: 'Delete Quest',
          ),
        ],
      ),
      body: questAsync.when(
        data: (quest) {
          if (quest == null) return const _QuestNotFound();
          return _QuestDetailBody(quest: quest);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _DetailError(
          error: error,
          onRetry: () => ref.invalidate(questByIdProvider(widget.questId)),
        ),
      ),
    );
  }

  /// Shown from a tap handler (a side-effect boundary), never from `build` —
  /// the dialog itself closes immediately on either choice (it holds no
  /// loading state of its own), so there is exactly one way to trigger a
  /// second confirmation: tapping the AppBar delete icon again, which is
  /// already disabled while [deleteQuestControllerProvider] is loading.
  Future<void> _confirmDelete(BuildContext context, Quest? quest) async {
    if (quest == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete quest?'),
        content: Text(
          'Delete "${quest.title}"? This removes the quest and its daily '
          'progress. XP you already earned from it is kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    ref.read(deleteQuestControllerProvider.notifier).delete(quest.id);
  }
}

class _QuestDetailBody extends ConsumerWidget {
  const _QuestDetailBody({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = ref.watch(todayUtcProvider);
    final progressAsync = ref.watch(
      questProgressForDateProvider(quest.id, today),
    );
    final transactionsAsync = ref.watch(
      xpTransactionsForQuestAndDateProvider(quest.id, today),
    );
    final baseXp = quest.attributeXpWeights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (quest.description.isNotEmpty)
            Text(quest.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          _QuestFacts(quest: quest, baseXp: baseXp),
          const SizedBox(height: AppSpacing.lg),
          QuestProgressSummary(
            progress: progressAsync.value,
            transactions: transactionsAsync.value ?? const [],
            isLoading: progressAsync.isLoading || transactionsAsync.isLoading,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProgressControls(quest: quest, progress: progressAsync.value),
        ],
      ),
    );
  }
}

/// Renders the interaction appropriate to [quest.progressType] — binary
/// keeps the existing `CompleteQuestButton`/`CompleteQuestController` pair
/// unchanged (already tested since Phase 5); quantity/duration go through
/// the new `QuestProgressController`.
class _ProgressControls extends ConsumerWidget {
  const _ProgressControls({required this.quest, required this.progress});

  final Quest quest;
  final QuestProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (quest.progressType) {
      case ProgressType.binary:
        return _BinaryControls(quest: quest, progress: progress);
      case ProgressType.quantity:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuantityQuestControls(quest: quest, progress: progress),
            _ProgressOperationError(),
          ],
        );
      case ProgressType.duration:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DurationQuestControls(quest: quest, progress: progress),
            _ProgressOperationError(),
          ],
        );
    }
  }
}

/// Binary quests jump straight from "not completed" to "completed" — once
/// [progress]`.isComplete` is true today, the Complete button is replaced
/// entirely (not just disabled) so an accidental extra tap has nothing to
/// hit. `CompleteQuestUseCase` itself does not refuse a repeat completion
/// (docs/architecture.md §3.3's diminishing-returns model deliberately
/// allows same-day repeats for quests that call it more than once) — this
/// is a UI-level guard against *accidental* re-completion, not a new domain
/// rule.
class _BinaryControls extends ConsumerWidget {
  const _BinaryControls({required this.quest, required this.progress});

  final Quest quest;
  final QuestProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedToday = progress?.isComplete ?? false;
    if (completedToday) {
      return const _CompletedBinaryIndicator();
    }

    final controllerState = ref.watch(completeQuestControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompleteQuestButton(
          isLoading: controllerState.isLoading,
          onPressed: () => _complete(ref),
        ),
        if (controllerState.hasError) ...[
          const SizedBox(height: AppSpacing.sm),
          _CompletionError(
            failure: controllerState.error,
            onRetry: () => _complete(ref),
          ),
        ],
      ],
    );
  }

  void _complete(WidgetRef ref) {
    final today = ref.read(todayUtcProvider);
    final command = CompleteQuestCommand(
      questId: quest.id,
      date: today,
      progressValue: quest.targetProgress,
    );
    ref.read(completeQuestControllerProvider.notifier).complete(command);
  }
}

class _CompletedBinaryIndicator extends StatelessWidget {
  const _CompletedBinaryIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Text(
            // Deliberately not "Completed today" — QuestProgressSummary
            // above already uses that exact string as a stat *label*
            // (present regardless of completion state), and this is a
            // separate, unconditional-on-this-screen status indicator.
            'Quest complete for today',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

/// Shared error banner for quantity/duration progress mutations — unlike
/// binary's [_CompletionError] (which retries the exact same action), a
/// failed increment/decrement has no single obvious action to retry, so
/// this just surfaces the message and lets the user dismiss it and try the
/// control again directly.
class _ProgressOperationError extends ConsumerWidget {
  const _ProgressOperationError();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questProgressControllerProvider);
    if (!state.hasError) return const SizedBox.shrink();

    final failure = state.error;
    final message = failure is Failure
        ? failure.message
        : 'Something went wrong. Please try again.';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(questProgressControllerProvider.notifier).reset(),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestFacts extends StatelessWidget {
  const _QuestFacts({required this.quest, required this.baseXp});

  final Quest quest;
  final int baseXp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FactRow(label: 'Type', value: questTypeDisplayName(quest.type)),
          const SizedBox(height: AppSpacing.xs),
          _FactRow(
            label: 'Difficulty',
            value: questDifficultyDisplayName(quest.difficulty),
          ),
          const SizedBox(height: AppSpacing.xs),
          _FactRow(label: 'Base XP', value: '$baseXp XP'),
          const SizedBox(height: AppSpacing.xs),
          _FactRow(
            label: 'Repeats',
            value: quest.repeatabilityRule ?? 'One-time',
          ),
          const SizedBox(height: AppSpacing.xs),
          _FactRow(
            label: 'Status',
            value: questCompletionStateDisplayName(quest.state),
          ),
          if (quest.attributeXpWeights.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Attribute allocation', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final entry in quest.attributeXpWeights.entries)
                  _FactRow(
                    label: attributeDisplayName(entry.key),
                    value: '${entry.value}',
                    compact: true,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.darkTextSecondary,
    );
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );

    if (compact) {
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
        child: Text('$label: $value', style: theme.textTheme.labelSmall),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
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
              "This quest doesn't exist or was removed.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // See quests_page.dart's `_QuestsError` for why the raw error is never
    // rendered directly (a ProviderException's toString() embeds its whole
    // stack trace, which caused a real layout overflow).
    debugPrint('Quest detail failed to load: $error');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load this quest.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Something went wrong loading this quest. Please try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _CompletionError extends StatelessWidget {
  const _CompletionError({required this.failure, required this.onRetry});

  final Object? failure;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = failure is Failure
        ? (failure as Failure).message
        : 'Something went wrong. Please try again.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Couldn\'t complete this quest',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.darkTextPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
