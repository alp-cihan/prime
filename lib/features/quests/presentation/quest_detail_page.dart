import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/domain/attribute_type.dart';
import '../../../core/domain/failure.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../xp_ledger/presentation/providers/xp_ledger_providers.dart';
import '../application/models/complete_quest_command.dart';
import '../application/models/complete_quest_result.dart';
import '../application/models/update_quest_progress_result.dart';
import '../domain/entities/quest.dart';
import '../domain/entities/quest_progress.dart';
import '../domain/entities/repeatability.dart';
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
              content: Text(
                AppLocalizations.of(
                  context,
                )!.questCompletedXp(result.totalXpAwarded),
              ),
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
                AppLocalizations.of(
                  context,
                )!.questCompletedXp(result.completionResult!.totalXpAwarded),
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

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          questAsync.value?.title ?? l10n.questFallbackTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Phase 19: Edit/Delete stay exactly here — small AppBar icons are
        // already visually subordinate to the redesigned body below, so no
        // further demotion was needed to satisfy "remain available but
        // visually subordinate."
        actions: [
          IconButton(
            onPressed: deleteState.isLoading
                ? null
                : () => context.go(AppRoutes.questEdit(widget.questId)),
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editQuestTooltip,
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
            tooltip: l10n.deleteQuestTooltip,
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteQuestDialogTitle),
        content: Text(l10n.deleteQuestDialogBody(quest.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    ref.read(deleteQuestControllerProvider.notifier).delete(quest.id);
  }
}

/// Phase 19 (Quest Detail redesign) visual hierarchy, top to bottom:
/// 1. [_QuestHero] — large lifestyle image, title, difficulty/attribute/XP.
/// 2. Progress — [QuestProgressSummary] (today's stats) plus the existing,
///    unmodified type-specific controls (binary/quantity/duration).
/// 3. [_PrimaryAction] — one obvious CTA; omitted once the quest is complete
///    (the Progress section above already shows that plainly).
/// 4. [_RewardSection] — total XP, attribute distribution, difficulty,
///    repeatability as compact chips, not a facts table.
/// 5. [_WhyThisMattersSection] — the quest's own description, only if one
///    exists; never invented copy.
class _QuestDetailBody extends ConsumerWidget {
  const _QuestDetailBody({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchor = ref.watch(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final progressAsync = ref.watch(
      questProgressForDateProvider(quest.id, anchor),
    );
    final transactionsAsync = ref.watch(
      xpTransactionsForQuestAndDateProvider(quest.id, anchor),
    );
    final progress = progressAsync.value;
    final baseXp = quest.attributeXpWeights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuestHero(quest: quest, baseXp: baseXp),
          const SizedBox(height: AppSpacing.lg),
          QuestProgressSummary(
            progress: progress,
            transactions: transactionsAsync.value ?? const [],
            isLoading: progressAsync.isLoading || transactionsAsync.isLoading,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProgressControls(quest: quest, progress: progress),
          const SizedBox(height: AppSpacing.lg),
          _PrimaryAction(quest: quest, progress: progress),
          const SizedBox(height: AppSpacing.lg),
          _RewardSection(quest: quest, baseXp: baseXp),
          const SizedBox(height: AppSpacing.lg),
          _WhyThisMattersSection(quest: quest),
        ],
      ),
    );
  }
}

/// The one image-forward element on the page — same `QuestVisual`/
/// `AssetVisualResolver` resolution as everywhere else a quest's
/// `visualKey` is shown (Today's hero, `QuestCard`), so a hand-typed quest
/// with no `visualKey` still falls back to the existing gradient
/// placeholder exactly as before. Deliberately no description text over the
/// image — `_WhyThisMattersSection` below is the one place the full
/// description reads comfortably, off the photo.
class _QuestHero extends StatelessWidget {
  const _QuestHero({required this.quest, required this.baseXp});

  final Quest quest;
  final int baseXp;

  static const _imageHeight = 200.0;
  static const _borderRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final primaryAttribute = _primaryAttribute(quest.attributeXpWeights);

    return GradientSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: _borderRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                QuestVisual(
                  seed: quest.visualKey ?? quest.id,
                  icon: primaryAttribute == null
                      ? null
                      : attributeIcon(primaryAttribute),
                  height: _imageHeight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(_borderRadius),
                  ),
                ),
                // Restrained dark scrim so an overlaid title stays readable
                // over any photo, without the image reading as decoration.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(_borderRadius),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.78),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Text(
                    quest.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _Chip(
                  label: questDifficultyDisplayName(context, quest.difficulty),
                ),
                if (primaryAttribute != null)
                  _Chip(
                    icon: attributeIcon(primaryAttribute),
                    label: attributeDisplayName(context, primaryAttribute),
                  ),
                _Chip(label: l10n.xpAmount(formatXp(baseXp))),
              ],
            ),
          ),
        ],
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

/// Renders the interaction appropriate to [quest.progressType] — binary
/// keeps the existing `CompleteQuestButton`/`CompleteQuestController` pair
/// unchanged (already tested since Phase 5); quantity/duration go through
/// the new `QuestProgressController`. Unchanged from before Phase 19 — this
/// is the "reuse existing progress behavior and controllers, do not
/// duplicate business logic" half of the redesign.
class _ProgressControls extends ConsumerWidget {
  const _ProgressControls({required this.quest, required this.progress});

  final Quest quest;
  final QuestProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (quest.progressType) {
      case ProgressType.binary:
        return const SizedBox.shrink();
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

/// Section 3 — the page's one obvious primary CTA. Binary reuses the
/// existing, already-tested [CompleteQuestButton]/[CompleteQuestController]
/// pair verbatim (unchanged label, unchanged behavior — nothing here
/// duplicates that logic). Quantity/duration get a new [_BeginContinueCta]:
/// there was previously no single "the one obvious action" button for those
/// types, only the granular +/-/quick-add controls above. Once the quest is
/// already complete today: binary shows [_CompletedBinaryIndicator] (its
/// `_ProgressControls` counterpart renders nothing at all for binary, so
/// this is the *only* place that state is ever shown — dropping it would
/// leave a completed binary quest with no confirmation anywhere on the
/// page); quantity/duration render nothing here, since their own controls
/// above already show a full bar with disabled buttons — a page that's
/// finished should feel finished, not keep offering a second action.
class _PrimaryAction extends ConsumerWidget {
  const _PrimaryAction({required this.quest, required this.progress});

  final Quest quest;
  final QuestProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedToday = progress?.isComplete ?? false;

    switch (quest.progressType) {
      case ProgressType.binary:
        return completedToday
            ? const _CompletedBinaryIndicator()
            : _BinaryPrimaryAction(quest: quest);
      case ProgressType.quantity:
      case ProgressType.duration:
        return completedToday
            ? const SizedBox.shrink()
            : _BeginContinueCta(quest: quest, progress: progress);
    }
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
            AppLocalizations.of(context)!.questCompleteForToday,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _BinaryPrimaryAction extends ConsumerWidget {
  const _BinaryPrimaryAction({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final anchor = ref.read(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final command = CompleteQuestCommand(
      questId: quest.id,
      date: anchor,
      progressValue: quest.targetProgress,
    );
    ref.read(completeQuestControllerProvider.notifier).complete(command);
  }
}

/// Quantity/duration's primary CTA — "Begin" before any progress exists
/// today, "Continue" once some does. Its tap action reuses
/// [QuestProgressController.increment] exactly as the smallest existing
/// control already does (the quantity controls' own `+1`, or duration's
/// smallest quick-add step) — no new business logic, just a more prominent,
/// single obvious entry point to the same mutation.
///
/// Deliberately its own widget with its own isolated `onPressed`, mirroring
/// Today's hero CTA (`HeroMissionCard`'s `_HeroCta`) — for duration quests
/// specifically, a later Prime Focus entry point only has to retarget this
/// one callback (e.g. to open a focus session instead of adding a flat
/// increment) without touching this page's layout at all.
class _BeginContinueCta extends ConsumerWidget {
  const _BeginContinueCta({required this.quest, required this.progress});

  final Quest quest;
  final QuestProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controllerState = ref.watch(questProgressControllerProvider);
    final started = (progress?.progressValue ?? 0) > 0;
    final label = started ? l10n.ctaContinue : l10n.heroCtaBegin;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: controllerState.isLoading ? null : () => _act(ref),
        child: controllerState.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }

  void _act(WidgetRef ref) {
    final anchor = ref.read(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final notifier = ref.read(questProgressControllerProvider.notifier);
    final step = quest.progressType == ProgressType.duration ? 5.0 : 1.0;
    notifier.increment(quest.id, anchor, amount: step);
  }
}

/// Shared error banner for quantity/duration progress mutations — unlike
/// binary's [_CompletionError] (which retries the exact same action), a
/// failed increment/decrement has no single obvious action to retry, so
/// this just surfaces the message and lets the user dismiss it and try the
/// control (or the primary CTA above) again directly.
class _ProgressOperationError extends ConsumerWidget {
  const _ProgressOperationError();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questProgressControllerProvider);
    if (!state.hasError) return const SizedBox.shrink();

    final failure = state.error;
    final message = failure is Failure
        ? failure.message
        : AppLocalizations.of(context)!.somethingWentWrong;

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
              child: Text(AppLocalizations.of(context)!.dismiss),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section 4 — what the quest is worth, as compact chips/cards rather than
/// the old label/value facts table: total XP (large, prominent), the
/// per-attribute distribution, difficulty, quest type, and repeatability
/// (only when it isn't a one-off).
class _RewardSection extends StatelessWidget {
  const _RewardSection({required this.quest, required this.baseXp});

  final Quest quest;
  final int baseXp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GradientSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.rewardSectionHeader, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatXp(baseXp),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'XP',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _Chip(label: questTypeDisplayName(context, quest.type)),
              _Chip(
                label: questDifficultyDisplayName(context, quest.difficulty),
              ),
              if (quest.repeatability != Repeatability.none)
                _Chip(
                  label: repeatabilityDisplayName(context, quest.repeatability),
                ),
            ],
          ),
          if (quest.attributeXpWeights.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.attributeAllocationLabel,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final entry in quest.attributeXpWeights.entries)
                  _Chip(
                    icon: attributeIcon(entry.key),
                    label:
                        '${attributeDisplayName(context, entry.key)} · '
                        '${entry.value}',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Section 5 — the quest's own description, presented as a short supportive
/// block. Renders nothing when there is none: this app never invents
/// motivational copy for a user-created quest (a hand-typed quest with an
/// empty description has nothing to say here, and that's fine).
class _WhyThisMattersSection extends StatelessWidget {
  const _WhyThisMattersSection({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    if (quest.description.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          Text(l10n.whyThisMattersHeader, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            quest.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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

class _CompletionError extends StatelessWidget {
  const _CompletionError({required this.failure, required this.onRetry});

  final Object? failure;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = failure is Failure
        ? (failure as Failure).message
        : l10n.somethingWentWrong;

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
            l10n.couldntCompleteQuest,
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
          OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});

  final String label;
  final IconData? icon;

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.darkTextSecondary),
            const SizedBox(width: 4),
          ],
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
