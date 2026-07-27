import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/clock.dart';
import '../../../../core/providers/persistence_providers.dart';
import '../../../xp_ledger/presentation/providers/xp_ledger_providers.dart';
import '../../application/services/achievement_evaluation_service.dart';
import '../../application/use_cases/evaluate_and_unlock_achievements_use_case.dart';
import '../../data/repositories/hive_achievement_unlock_repository.dart';
import '../../domain/repositories/achievement_unlock_repository.dart';
import '../../domain/services/achievement_evaluation_policy.dart';

part 'achievement_repository_providers.g.dart';

/// Singleton for the app's lifetime — wraps the already-open unlock box,
/// same pattern as `xpLedgerRepositoryProvider`.
@Riverpod(keepAlive: true)
AchievementUnlockRepository achievementUnlockRepository(Ref ref) =>
    HiveAchievementUnlockRepository(
      ref.watch(achievementUnlockHiveBoxProvider),
    );

@Riverpod(keepAlive: true)
AchievementEvaluationPolicy achievementEvaluationPolicy(Ref ref) =>
    const AchievementEvaluationPolicy();

@Riverpod(keepAlive: true)
Clock achievementClock(Ref ref) => const SystemClock();

@Riverpod(keepAlive: true)
AchievementEvaluationService achievementEvaluationService(Ref ref) {
  return AchievementEvaluationService(
    xpLedgerRepository: ref.watch(xpLedgerRepositoryProvider),
    unlockRepository: ref.watch(achievementUnlockRepositoryProvider),
    policy: ref.watch(achievementEvaluationPolicyProvider),
  );
}

@Riverpod(keepAlive: true)
EvaluateAndUnlockAchievementsUseCase evaluateAndUnlockAchievementsUseCase(
  Ref ref,
) {
  return EvaluateAndUnlockAchievementsUseCase(
    evaluationService: ref.watch(achievementEvaluationServiceProvider),
    unlockRepository: ref.watch(achievementUnlockRepositoryProvider),
    xpLedgerRepository: ref.watch(xpLedgerRepositoryProvider),
    clock: ref.watch(achievementClockProvider),
  );
}
