import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/persistence_providers.dart';
import '../../../xp_ledger/presentation/providers/xp_ledger_providers.dart';
import '../../application/clock.dart';
import '../../application/use_cases/complete_quest_use_case.dart';
import '../../data/repositories/hive_quest_progress_repository.dart';
import '../../data/repositories/hive_quest_repository.dart';
import '../../domain/repositories/quest_progress_repository.dart';
import '../../domain/repositories/quest_repository.dart';
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

@Riverpod(keepAlive: true)
QuestXpCalculator questXpCalculator(Ref ref) => const QuestXpCalculator();

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
    calculator: ref.watch(questXpCalculatorProvider),
    clock: ref.watch(clockProvider),
  );
}
