import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/identity/application/services/identity_service.dart';
import 'package:prime/features/identity/application/use_cases/load_identity_snapshot_use_case.dart';
import 'package:prime/features/identity/domain/entities/identity_snapshot.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/domain/repositories/xp_ledger_repository.dart';

import '../../../support/fake_repositories.dart';

class _ThrowingXpLedgerRepository implements XpLedgerRepository {
  @override
  Future<void> appendAll(List<XpTransaction> transactions) async =>
      throw StateError('ledger unavailable');

  @override
  Future<List<XpTransaction>> getAll() async =>
      throw StateError('ledger unavailable');

  @override
  Future<List<XpTransaction>> getTransactionsForQuestAndDate(
    String questId,
    DateTime date,
  ) async => throw UnimplementedError();

  @override
  Future<List<XpTransaction>> getTransactionsForQuest(String questId) async =>
      throw UnimplementedError();

  @override
  Future<List<XpTransaction>> getTransactionsForDate(DateTime date) async =>
      throw UnimplementedError();

  @override
  Future<int> sumLifetimeXp() async => throw UnimplementedError();

  @override
  Future<int> sumXpForAttribute(AttributeType type) async =>
      throw UnimplementedError();
}

void main() {
  test('execute wraps a successfully built snapshot in Ok', () async {
    final useCase = LoadIdentitySnapshotUseCase(
      identityService: IdentityService(
        xpLedgerRepository: FakeXpLedgerRepository(),
        achievementUnlockRepository: FakeAchievementUnlockRepository(),
        chainProgressRepository: FakeChainProgressRepository(),
        achievements: const [],
        chains: const [],
      ),
    );

    final result = await useCase.execute();

    expect(result, isA<Ok<IdentitySnapshot>>());
    expect((result as Ok<IdentitySnapshot>).value.currentLevel, 1);
  });

  test('execute wraps a repository failure in Err', () async {
    final useCase = LoadIdentitySnapshotUseCase(
      identityService: IdentityService(
        xpLedgerRepository: _ThrowingXpLedgerRepository(),
        achievementUnlockRepository: FakeAchievementUnlockRepository(),
        chainProgressRepository: FakeChainProgressRepository(),
        achievements: const [],
        chains: const [],
      ),
    );

    final result = await useCase.execute();

    expect(result, isA<Err<IdentitySnapshot>>());
  });
}
