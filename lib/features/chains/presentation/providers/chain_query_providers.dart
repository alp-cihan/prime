import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/chain.dart';
import '../../domain/entities/chain_progress.dart';
import '../../domain/entities/chain_stage.dart';
import '../../domain/services/chain_progress_policy.dart';
import '../models/chain_with_progress.dart';
import 'chain_repository_providers.dart';

part 'chain_query_providers.g.dart';

/// Emits the current progress list immediately, then again on every
/// subsequent change (`HiveChainProgressRepository.watchAll`'s
/// `Box.watch()`-backed contract).
@riverpod
Stream<List<ChainProgress>> watchAllChainProgress(Ref ref) {
  final repository = ref.watch(chainProgressRepositoryProvider);
  return repository.watchAll();
}

ChainWithProgress _buildView(
  Chain chain,
  ChainProgress? stored,
  ChainProgressPolicy policy,
) {
  final progress = stored ?? policy.initial(chain.id);
  final stages = policy.stagesFor(chain, progress);
  final currentIndex = policy.currentStageIndex(chain, progress);
  return ChainWithProgress(
    chain: chain,
    progress: progress,
    stages: stages,
    completionPercent: policy.completionPercent(chain, progress),
    currentStage: currentIndex == null ? null : stages[currentIndex],
    isCompleted: policy.isCompleted(chain, progress),
    hasStarted: policy.hasStarted(progress),
  );
}

/// Every catalog chain paired with its derived progress — the single
/// composition point every other provider in this file derives from, so
/// there is exactly one place that turns "a chain + its stored progress
/// row" into the full view model.
@riverpod
Future<List<ChainWithProgress>> allChainsWithProgress(Ref ref) async {
  final progressList = await ref.watch(watchAllChainProgressProvider.future);
  final byId = {for (final p in progressList) p.chainId: p};
  final catalog = ref.watch(chainCatalogListProvider);
  final policy = ref.watch(chainProgressPolicyProvider);

  return [
    for (final chain in catalog) _buildView(chain, byId[chain.id], policy),
  ];
}

/// Chains not yet completed — the Chains page's "Active" section.
@riverpod
Future<List<ChainWithProgress>> activeChains(Ref ref) async {
  final all = await ref.watch(allChainsWithProgressProvider.future);
  return all.where((c) => !c.isCompleted).toList();
}

/// Chains fully completed — the Chains page's "Completed" section.
@riverpod
Future<List<ChainWithProgress>> completedChains(Ref ref) async {
  final all = await ref.watch(allChainsWithProgressProvider.future);
  return all.where((c) => c.isCompleted).toList();
}

/// One chain's full view, for the Chain Detail page — `null` if [chainId]
/// isn't in the catalog.
@riverpod
Future<ChainWithProgress?> chainDetail(Ref ref, String chainId) async {
  final all = await ref.watch(allChainsWithProgressProvider.future);
  for (final entry in all) {
    if (entry.chain.id == chainId) return entry;
  }
  return null;
}

/// Just the current stage for one chain — `null` once it's completed (or
/// if [chainId] isn't in the catalog).
@riverpod
Future<ChainStage?> currentChainStage(Ref ref, String chainId) async {
  final detail = await ref.watch(chainDetailProvider(chainId).future);
  return detail?.currentStage;
}
