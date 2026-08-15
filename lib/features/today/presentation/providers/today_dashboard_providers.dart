import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/attribute_type.dart';
import '../../../quests/domain/entities/quest.dart';
import '../../../quests/presentation/providers/quest_query_providers.dart';
import '../../../quests/presentation/providers/quest_repository_providers.dart';
import '../../../xp_ledger/domain/entities/xp_transaction.dart';
import '../../../xp_ledger/presentation/providers/xp_ledger_providers.dart';

part 'today_dashboard_providers.g.dart';

/// Today's quest-completion summary (the §13.2 "Daily Score" ring's data —
/// deliberately just a completion ratio over active quests, not a stored
/// score model of its own; docs/architecture.md's Daily Score formula is a
/// later-phase concern, this is the Phase 6 MVP substitute).
class TodayQuestProgressSummary {
  final int totalActiveQuests;
  final int completedToday;

  const TodayQuestProgressSummary({
    required this.totalActiveQuests,
    required this.completedToday,
  });

  double get completionRatio =>
      totalActiveQuests == 0 ? 0.0 : completedToday / totalActiveQuests;

  @override
  bool operator ==(Object other) =>
      other is TodayQuestProgressSummary &&
      other.totalActiveQuests == totalActiveQuests &&
      other.completedToday == completedToday;

  @override
  int get hashCode => Object.hash(totalActiveQuests, completedToday);
}

/// A quest that has expired or been converted (e.g. into a Recovery Quest)
/// is no longer something the dashboard should feature or count — everything
/// else is "active" for Phase 6's purposes (no daily-reset engine exists
/// yet; that is a later-phase concern).
bool _isActiveQuest(Quest quest) =>
    quest.state != QuestCompletionState.expired &&
    quest.state != QuestCompletionState.converted;

/// Completed-today count and active-quest total for the Daily Progress
/// card. Watches each active quest's [questProgressForDateProvider] instance
/// directly (rather than re-deriving from a repository read of its own) so
/// that `CompleteQuestController`'s existing invalidation of that exact
/// family provider automatically recomputes this summary too — no separate
/// invalidation wiring needed for this provider.
@riverpod
Future<TodayQuestProgressSummary> todayQuestProgressSummary(Ref ref) async {
  final quests = await ref.watch(watchAllQuestsProvider.future);
  final activeQuests = quests.where(_isActiveQuest).toList();

  var completedToday = 0;
  for (final quest in activeQuests) {
    final anchor = ref.watch(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final progress = await ref.watch(
      questProgressForDateProvider(quest.id, anchor).future,
    );
    if (progress?.isComplete ?? false) completedToday++;
  }

  return TodayQuestProgressSummary(
    totalActiveQuests: activeQuests.length,
    completedToday: completedToday,
  );
}

/// Shared by [featuredQuest] and [continueQuest]: the first quest in
/// [activeQuests] not yet completed today, or the first quest if every one
/// already is. Deliberately a plain helper rather than having [continueQuest]
/// watch [featuredQuestProvider] itself — two independent async providers
/// each watching the same `questProgressForDateProvider` family member via
/// `.future`, one of them reached indirectly through another provider's
/// `.future`, trips a Riverpod-internal subscription-pause assertion
/// (`pausedActiveSubscriptionCount` mismatch) under rapid rebuilds (e.g. tab
/// navigation). Recomputing the same small, already-tested rule locally
/// avoids that shared dependency path entirely.
Future<Quest> _selectFeatured(Ref ref, List<Quest> activeQuests) async {
  for (final quest in activeQuests) {
    final anchor = ref.watch(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final progress = await ref.watch(
      questProgressForDateProvider(quest.id, anchor).future,
    );
    if (!(progress?.isComplete ?? false)) return quest;
  }
  return activeQuests.first;
}

/// The Main Quest card's selection (docs/architecture.md §13.3): the first
/// active quest not yet completed today, in [watchAllQuestsProvider]'s own
/// deterministic order; if every active quest is already complete, falls
/// back to the first active quest; `null` only when there are no active
/// quests at all (the empty state).
@riverpod
Future<Quest?> featuredQuest(Ref ref) async {
  final quests = await ref.watch(watchAllQuestsProvider.future);
  final activeQuests = quests.where(_isActiveQuest).toList();
  if (activeQuests.isEmpty) return null;
  return _selectFeatured(ref, activeQuests);
}

/// Phase 18 — the Today 2.0 "Continue" section's selection: the first
/// active, non-binary quest (quantity/duration — binary quests are only ever
/// "done" or "not done," so they have no partial "progress" to continue)
/// that already has measurable progress today (`progressValue > 0`) but
/// isn't complete yet, excluding whichever quest [featuredQuest]'s same
/// selection rule already put in the hero card — Continue exists to surface
/// a *second* quest worth resuming, never to duplicate the hero. Same
/// deterministic ordering as [featuredQuest] ([watchAllQuestsProvider]'s own
/// order); `null` when nothing qualifies, which is exactly when the
/// presentation layer omits the section entirely.
@riverpod
Future<Quest?> continueQuest(Ref ref) async {
  final quests = await ref.watch(watchAllQuestsProvider.future);
  final activeQuests = quests.where(_isActiveQuest).toList();
  if (activeQuests.isEmpty) return null;
  final featuredId = (await _selectFeatured(ref, activeQuests)).id;

  for (final quest in activeQuests) {
    if (quest.id == featuredId) continue;
    if (quest.progressType == ProgressType.binary) continue;
    final anchor = ref.watch(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final progress = await ref.watch(
      questProgressForDateProvider(quest.id, anchor).future,
    );
    if (progress == null) continue;
    if (progress.isComplete) continue;
    if (progress.progressValue <= 0) continue;
    return quest;
  }
  return null;
}

/// Every XP transaction recorded today, across all quests — the Activity/XP
/// Summary section's source of truth.
@riverpod
Future<List<XpTransaction>> todayXpTransactions(Ref ref) {
  final today = ref.watch(todayUtcProvider);
  return ref.watch(xpTransactionsForDateProvider(today).future);
}

@riverpod
Future<int> todayXpTotal(Ref ref) async {
  final transactions = await ref.watch(todayXpTransactionsProvider.future);
  return transactions.fold<int>(0, (sum, t) => sum + t.finalXp);
}

/// Only attributes with at least one XP transaction today are present in
/// the result — the caller is not expected to render eight zero-value rows.
@riverpod
Future<Map<AttributeType, int>> todayXpByAttribute(Ref ref) async {
  final transactions = await ref.watch(todayXpTransactionsProvider.future);
  final result = <AttributeType, int>{};
  for (final transaction in transactions) {
    result[transaction.attribute] =
        (result[transaction.attribute] ?? 0) + transaction.finalXp;
  }
  return result;
}
