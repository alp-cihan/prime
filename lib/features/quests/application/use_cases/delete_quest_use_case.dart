import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../domain/entities/quest.dart';
import '../../domain/repositories/quest_progress_repository.dart';
import '../../domain/repositories/quest_repository.dart';
import '../models/delete_quest_command.dart';

/// Deletes a [Quest]. Returns `Ok(true)` on success.
///
/// ## Deletion policy
/// docs/architecture.md defines no cascading-delete rule for RPG entities.
/// This use case removes:
/// - the [Quest] record itself, and
/// - every [QuestProgress] row for it (`QuestProgressRepository
///   .deleteAllForQuest`) — a progress row has no purpose once its quest is
///   gone and no other feature reads it independently of the quest.
///
/// It never removes `XpTransaction` rows. CLAUDE.md: "XP transactions are
/// immutable and append-only" — a deleted quest's past completions still
/// genuinely happened, and the ledger (lifetime XP, per-attribute totals,
/// the You tab's summary) must keep reflecting them. Nothing in the
/// architecture calls for cascading that deletion, so it deliberately isn't
/// implemented here.
///
/// ## Missing quest
/// Returns [NotFoundFailure] rather than treating a missing id as a silent
/// success — consistent with [CompleteQuestUseCase]'s same choice, and it
/// lets the UI distinguish "already gone" from "just deleted" if that ever
/// matters.
///
/// ## Ordering / partial failure
/// [QuestProgressRepository.deleteAllForQuest] runs *before*
/// [QuestRepository.deleteById]. Hive's local box writes have no
/// cross-box transaction boundary, so a failure between the two steps is a
/// real (if narrow, no-network-involved) possibility; this order means such
/// a failure leaves the quest still visible with its progress already
/// cleared, rather than an orphaned progress row pointing at a quest that no
/// longer exists.
class DeleteQuestUseCase {
  const DeleteQuestUseCase({
    required QuestRepository questRepository,
    required QuestProgressRepository questProgressRepository,
  }) : _questRepository = questRepository,
       _questProgressRepository = questProgressRepository;

  final QuestRepository _questRepository;
  final QuestProgressRepository _questProgressRepository;

  Future<Result<bool>> execute(DeleteQuestCommand command) async {
    final Quest? existing;
    try {
      existing = await _questRepository.getById(command.questId);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load quest: $e'));
    }
    if (existing == null) {
      return Err(NotFoundFailure('Quest "${command.questId}" was not found'));
    }

    try {
      await _questProgressRepository.deleteAllForQuest(command.questId);
      await _questRepository.deleteById(command.questId);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to delete quest: $e'));
    }

    return const Ok(true);
  }
}
