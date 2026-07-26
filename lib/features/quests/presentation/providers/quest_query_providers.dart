import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_progress.dart';
import 'quest_repository_providers.dart';

part 'quest_query_providers.g.dart';

/// Emits the current persisted quest list immediately, then again on every
/// subsequent repository change (see `HiveQuestRepository.watchAll`). This
/// is a single riverpod provider, so every widget that watches it shares
/// the one underlying `Box.watch()` subscription — no duplicate listeners
/// are created no matter how many consumers watch it.
@riverpod
Stream<List<Quest>> watchAllQuests(Ref ref) {
  final repository = ref.watch(questRepositoryProvider);
  return repository.watchAll();
}

/// Null when no quest exists for [questId] — architecture.md does not
/// define a failure object for a missing quest lookup (only
/// `CompleteQuestUseCase`'s own `NotFoundFailure`, which is specific to the
/// completion flow), so this passes `QuestRepository.getById`'s own
/// nullable result straight through.
@riverpod
Future<Quest?> questById(Ref ref, String questId) {
  final repository = ref.watch(questRepositoryProvider);
  return repository.getById(questId);
}

/// Progress for one `(questId, date)`. [date] must already be
/// UTC-date-normalized for the same reason documented on
/// `xpTransactionsForQuestAndDateProvider` — the family cache key is the
/// exact [date] value passed in.
@riverpod
Future<QuestProgress?> questProgressForDate(
  Ref ref,
  String questId,
  DateTime date,
) {
  final repository = ref.watch(questProgressRepositoryProvider);
  return repository.getForQuestAndDate(questId, date);
}
