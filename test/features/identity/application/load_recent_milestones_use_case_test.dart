import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';
import 'package:prime/features/identity/application/services/identity_service.dart';
import 'package:prime/features/identity/application/use_cases/load_recent_milestones_use_case.dart';
import 'package:prime/features/identity/domain/entities/identity_milestone.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/achievements/domain/repositories/achievement_unlock_repository.dart';

import '../../../support/fake_repositories.dart';

class _ThrowingAchievementUnlockRepository
    implements AchievementUnlockRepository {
  @override
  Future<List<AchievementUnlock>> getAll() async =>
      throw StateError('unlocks unavailable');

  @override
  Future<bool> isUnlocked(String achievementId) async =>
      throw UnimplementedError();

  @override
  Stream<List<AchievementUnlock>> watchAll() => throw UnimplementedError();

  @override
  Future<void> appendAll(List<AchievementUnlock> newUnlocks) async =>
      throw UnimplementedError();
}

void main() {
  test('execute wraps recent milestones in Ok, newest first', () async {
    final ledger = FakeXpLedgerRepository()
      ..byKey['a'] = XpTransaction(
        id: 'q1|2026-01-05|0|health',
        sourceType: XpSourceType.quest,
        sourceId: 'q1|2026-01-05|0',
        attribute: AttributeType.health,
        baseXp: 100,
        modifiersApplied: const {},
        finalXp: 100,
        createdAt: DateTime.utc(2026, 1, 5),
        idempotencyKey: 'q1|2026-01-05|0|health',
      );
    final useCase = LoadRecentMilestonesUseCase(
      identityService: IdentityService(
        xpLedgerRepository: ledger,
        achievementUnlockRepository: FakeAchievementUnlockRepository(),
        chainProgressRepository: FakeChainProgressRepository(),
        achievements: const [],
        chains: const [],
      ),
    );

    final result = await useCase.execute();

    expect(result, isA<Ok<List<IdentityMilestone>>>());
    final milestones = (result as Ok<List<IdentityMilestone>>).value;
    expect(milestones.single.type, IdentityMilestoneType.levelReached);
  });

  test('execute wraps a repository failure in Err', () async {
    final useCase = LoadRecentMilestonesUseCase(
      identityService: IdentityService(
        xpLedgerRepository: FakeXpLedgerRepository(),
        achievementUnlockRepository: _ThrowingAchievementUnlockRepository(),
        chainProgressRepository: FakeChainProgressRepository(),
        achievements: const [],
        chains: const [],
      ),
    );

    final result = await useCase.execute();

    expect(result, isA<Err<List<IdentityMilestone>>>());
  });

  test('execute respects the limit parameter', () async {
    final ledger = FakeXpLedgerRepository()
      ..byKey['a'] = XpTransaction(
        id: 'q1|2026-01-05|0|health',
        sourceType: XpSourceType.quest,
        sourceId: 'q1|2026-01-05|0',
        attribute: AttributeType.health,
        baseXp: 500,
        modifiersApplied: const {},
        finalXp: 500,
        createdAt: DateTime.utc(2026, 1, 5),
        idempotencyKey: 'q1|2026-01-05|0|health',
      );
    final useCase = LoadRecentMilestonesUseCase(
      identityService: IdentityService(
        xpLedgerRepository: ledger,
        achievementUnlockRepository: FakeAchievementUnlockRepository(),
        chainProgressRepository: FakeChainProgressRepository(),
        achievements: const [],
        chains: const [],
      ),
    );

    final result = await useCase.execute(limit: 1);

    final milestones = (result as Ok<List<IdentityMilestone>>).value;
    expect(milestones.length, 1);
  });
}
