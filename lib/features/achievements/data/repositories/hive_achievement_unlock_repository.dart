import 'package:hive_ce/hive.dart';

import '../../domain/entities/achievement_unlock.dart';
import '../../domain/repositories/achievement_unlock_repository.dart';
import '../mappers/achievement_unlock_mapper.dart';
import '../models/achievement_unlock_hive_model.dart';

/// Hive CE-backed [AchievementUnlockRepository]. The box is keyed by
/// [AchievementUnlock.achievementId] itself — an achievement unlocks at most
/// once, ever, so there is no separate id/timestamp needed to make the key
/// unique, and a `put` under an already-present key would silently
/// overwrite [AchievementUnlock.unlockedAt]/`rewardIdempotencyKey`, which
/// [appendAll] guards against exactly like `HiveXpLedgerRepository` guards
/// its own idempotency-key dedup.
class HiveAchievementUnlockRepository implements AchievementUnlockRepository {
  HiveAchievementUnlockRepository(
    this._box, {
    AchievementUnlockMapper mapper = const AchievementUnlockMapper(),
  }) : _mapper = mapper;

  final Box<AchievementUnlockHiveModel> _box;
  final AchievementUnlockMapper _mapper;

  @override
  Future<List<AchievementUnlock>> getAll() async => _readAll();

  @override
  Future<bool> isUnlocked(String achievementId) async =>
      _box.containsKey(achievementId);

  @override
  Stream<List<AchievementUnlock>> watchAll() async* {
    yield _readAll();
    yield* _box.watch().map((_) => _readAll());
  }

  List<AchievementUnlock> _readAll() =>
      _box.values.map(_mapper.toDomain).toList();

  @override
  Future<void> appendAll(List<AchievementUnlock> unlocks) async {
    for (final unlock in unlocks) {
      if (_box.containsKey(unlock.achievementId)) {
        continue; // Append-only: an existing unlock is never overwritten.
      }
      await _box.put(unlock.achievementId, _mapper.toModel(unlock));
    }
  }
}
