import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/clock.dart';
import '../../../achievements/presentation/providers/achievement_repository_providers.dart';
import '../../../chains/presentation/providers/chain_repository_providers.dart';
import '../../../xp_ledger/presentation/providers/xp_ledger_providers.dart';
import '../../application/services/identity_service.dart';
import '../../application/use_cases/load_identity_snapshot_use_case.dart';
import '../../application/use_cases/load_recent_milestones_use_case.dart';

part 'identity_repository_providers.g.dart';

@Riverpod(keepAlive: true)
Clock identityClock(Ref ref) => const SystemClock();

/// Composes the identity feature's single read-only service from
/// repositories/catalogs three OTHER features already own — this feature
/// introduces no repository or persisted state of its own (Phase 12: "Do
/// not introduce duplicated persistence").
@Riverpod(keepAlive: true)
IdentityService identityService(Ref ref) {
  return IdentityService(
    xpLedgerRepository: ref.watch(xpLedgerRepositoryProvider),
    achievementUnlockRepository: ref.watch(achievementUnlockRepositoryProvider),
    chainProgressRepository: ref.watch(chainProgressRepositoryProvider),
    achievements: ref.watch(achievementCatalogListProvider),
    chains: ref.watch(chainCatalogListProvider),
    clock: ref.watch(identityClockProvider),
  );
}

@Riverpod(keepAlive: true)
LoadIdentitySnapshotUseCase loadIdentitySnapshotUseCase(Ref ref) {
  return LoadIdentitySnapshotUseCase(
    identityService: ref.watch(identityServiceProvider),
  );
}

@Riverpod(keepAlive: true)
LoadRecentMilestonesUseCase loadRecentMilestonesUseCase(Ref ref) {
  return LoadRecentMilestonesUseCase(
    identityService: ref.watch(identityServiceProvider),
  );
}
