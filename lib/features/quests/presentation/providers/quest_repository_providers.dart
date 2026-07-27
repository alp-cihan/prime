import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/persistence_providers.dart';
import '../../../xp_ledger/presentation/providers/xp_ledger_providers.dart';
import '../../application/clock.dart';
import '../../application/id_generator.dart';
import '../../application/services/quest_occurrence_service.dart';
import '../../application/use_cases/complete_quest_use_case.dart';
import '../../application/use_cases/create_quest_use_case.dart';
import '../../application/use_cases/delete_quest_use_case.dart';
import '../../application/use_cases/update_quest_progress_use_case.dart';
import '../../application/use_cases/update_quest_use_case.dart';
import '../../data/repositories/hive_quest_progress_repository.dart';
import '../../data/repositories/hive_quest_repository.dart';
import '../../domain/entities/repeatability.dart';
import '../../domain/repositories/quest_progress_repository.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../domain/services/quest_input_validator.dart';
import '../../domain/services/quest_occurrence_policy.dart';
import '../../domain/services/quest_progress_policy.dart';
import '../../domain/services/quest_xp_calculator.dart';

part 'quest_repository_providers.g.dart';

/// Singletons for the app's lifetime — each wraps an already-open Hive box
/// (see `persistence_providers.dart`) and holds no other state, so there is
/// nothing to reset or leak by keeping exactly one instance alive.
@Riverpod(keepAlive: true)
QuestRepository questRepository(Ref ref) =>
    HiveQuestRepository(ref.watch(questHiveBoxProvider));

@Riverpod(keepAlive: true)
QuestProgressRepository questProgressRepository(Ref ref) =>
    HiveQuestProgressRepository(ref.watch(questProgressHiveBoxProvider));

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();

/// Today, normalized to a UTC date-only value — the same normalization
/// `CompleteQuestUseCase` and the Hive repositories already apply. Backed by
/// [clockProvider] so overriding that one provider in tests (a fixed
/// [Clock]) deterministically controls "today" everywhere in the UI too.
@riverpod
DateTime todayUtc(Ref ref) {
  final now = ref.watch(clockProvider).now();
  return DateTime.utc(now.year, now.month, now.day);
}

@Riverpod(keepAlive: true)
QuestXpCalculator questXpCalculator(Ref ref) => const QuestXpCalculator();

/// Phase 9 — the occurrence model's pure-domain policy (boundaries,
/// eligibility, anchor dates) and its application-layer composition with the
/// XP ledger (repeat index, prior-XP-this-occurrence, first-completion-ever).
@Riverpod(keepAlive: true)
QuestOccurrencePolicy questOccurrencePolicy(Ref ref) =>
    const QuestOccurrencePolicy();

@Riverpod(keepAlive: true)
QuestOccurrenceService questOccurrenceService(Ref ref) {
  return QuestOccurrenceService(
    xpLedgerRepository: ref.watch(xpLedgerRepositoryProvider),
    policy: ref.watch(questOccurrencePolicyProvider),
  );
}

/// The date to read/write a given [repeatability]'s `QuestProgress` under
/// right now — a UI-facing wrapper over [QuestOccurrencePolicy.resolve], so
/// no widget ever computes an occurrence boundary itself (Phase 9: "Widgets
/// must never calculate dates"). Backed by [clockProvider] for the same
/// testability reason as [todayUtcProvider]. Keyed by [Repeatability] alone
/// (not by quest id) since the anchor date only depends on the cadence and
/// the clock — every quest sharing a cadence shares the same anchor, so
/// Riverpod caches and invalidates exactly one instance per cadence.
@riverpod
DateTime questOccurrenceAnchorDate(Ref ref, Repeatability repeatability) {
  final now = ref.watch(clockProvider).now();
  return ref
      .watch(questOccurrencePolicyProvider)
      .resolve(repeatability: repeatability, instant: now)
      .anchorDate;
}

/// Composes the quest-completion use case from the repository/service
/// singletons above plus [xpLedgerRepositoryProvider] (xp_ledger feature).
/// `CompleteQuestUseCase` itself holds no mutable state, so recreating it
/// costs nothing, but it is kept alive for consistency with its
/// dependencies and to avoid rebuilding it on every unrelated rebuild.
@Riverpod(keepAlive: true)
CompleteQuestUseCase completeQuestUseCase(Ref ref) {
  return CompleteQuestUseCase(
    questRepository: ref.watch(questRepositoryProvider),
    questProgressRepository: ref.watch(questProgressRepositoryProvider),
    xpLedgerRepository: ref.watch(xpLedgerRepositoryProvider),
    occurrenceService: ref.watch(questOccurrenceServiceProvider),
    calculator: ref.watch(questXpCalculatorProvider),
    clock: ref.watch(clockProvider),
  );
}

@Riverpod(keepAlive: true)
IdGenerator idGenerator(Ref ref) => const UuidV4IdGenerator();

@Riverpod(keepAlive: true)
QuestInputValidator questInputValidator(Ref ref) => const QuestInputValidator();

/// Phase 7 write-side use cases — composed from the same repository/service
/// singletons above, kept alive for the same reasons as
/// [completeQuestUseCaseProvider].
@Riverpod(keepAlive: true)
CreateQuestUseCase createQuestUseCase(Ref ref) {
  return CreateQuestUseCase(
    questRepository: ref.watch(questRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
    validator: ref.watch(questInputValidatorProvider),
  );
}

@Riverpod(keepAlive: true)
UpdateQuestUseCase updateQuestUseCase(Ref ref) {
  return UpdateQuestUseCase(
    questRepository: ref.watch(questRepositoryProvider),
    validator: ref.watch(questInputValidatorProvider),
  );
}

@Riverpod(keepAlive: true)
DeleteQuestUseCase deleteQuestUseCase(Ref ref) {
  return DeleteQuestUseCase(
    questRepository: ref.watch(questRepositoryProvider),
    questProgressRepository: ref.watch(questProgressRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
QuestProgressPolicy questProgressPolicy(Ref ref) => const QuestProgressPolicy();

/// Phase 8's progress-mutation use case — composed from the same
/// repository singletons plus [completeQuestUseCaseProvider], which it
/// delegates every completion to (see that use case's own doc for why it
/// never awards XP itself).
@Riverpod(keepAlive: true)
UpdateQuestProgressUseCase updateQuestProgressUseCase(Ref ref) {
  return UpdateQuestProgressUseCase(
    questRepository: ref.watch(questRepositoryProvider),
    questProgressRepository: ref.watch(questProgressRepositoryProvider),
    completeQuestUseCase: ref.watch(completeQuestUseCaseProvider),
    policy: ref.watch(questProgressPolicyProvider),
    occurrencePolicy: ref.watch(questOccurrencePolicyProvider),
  );
}
