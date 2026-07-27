import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/clock.dart';
import '../../../../core/providers/persistence_providers.dart';
import '../../../xp_ledger/presentation/providers/xp_ledger_providers.dart';
import '../../application/services/chain_evaluation_service.dart';
import '../../application/use_cases/evaluate_and_advance_chains_use_case.dart';
import '../../data/repositories/hive_chain_progress_repository.dart';
import '../../domain/catalog/chain_catalog.dart';
import '../../domain/entities/chain.dart';
import '../../domain/repositories/chain_progress_repository.dart';
import '../../domain/services/chain_progress_policy.dart';

part 'chain_repository_providers.g.dart';

/// The built-in catalog, sorted by [Chain.sortOrder] — declared here (not
/// in `chain_query_providers.dart`, which depends on this file) so
/// [evaluateAndAdvanceChainsUseCaseProvider] below can read the *same*
/// provider a test might override, rather than silently falling back to
/// the raw `chainCatalog` constant regardless of any override. Every other
/// provider in this file/feature reads the catalog through here.
@Riverpod(keepAlive: true)
List<Chain> chainCatalogList(Ref ref) {
  final sorted = List<Chain>.of(chainCatalog)
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return sorted;
}

/// Singleton for the app's lifetime — wraps the already-open chain
/// progress box, same pattern as `achievementUnlockRepositoryProvider`.
@Riverpod(keepAlive: true)
ChainProgressRepository chainProgressRepository(Ref ref) =>
    HiveChainProgressRepository(ref.watch(chainProgressHiveBoxProvider));

@Riverpod(keepAlive: true)
ChainProgressPolicy chainProgressPolicy(Ref ref) => const ChainProgressPolicy();

@Riverpod(keepAlive: true)
Clock chainClock(Ref ref) => const SystemClock();

@Riverpod(keepAlive: true)
ChainEvaluationService chainEvaluationService(Ref ref) {
  return ChainEvaluationService(
    xpLedgerRepository: ref.watch(xpLedgerRepositoryProvider),
    progressRepository: ref.watch(chainProgressRepositoryProvider),
    policy: ref.watch(chainProgressPolicyProvider),
  );
}

@Riverpod(keepAlive: true)
EvaluateAndAdvanceChainsUseCase evaluateAndAdvanceChainsUseCase(Ref ref) {
  return EvaluateAndAdvanceChainsUseCase(
    evaluationService: ref.watch(chainEvaluationServiceProvider),
    progressRepository: ref.watch(chainProgressRepositoryProvider),
    xpLedgerRepository: ref.watch(xpLedgerRepositoryProvider),
    catalog: ref.watch(chainCatalogListProvider),
    clock: ref.watch(chainClockProvider),
  );
}
