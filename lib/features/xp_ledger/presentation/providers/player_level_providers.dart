import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/services/level_curve.dart';
import '../models/player_level_summary.dart';
import 'xp_ledger_providers.dart';

part 'player_level_providers.g.dart';

/// docs/architecture.md §4.1 — the global player level uses `base: 100`;
/// `base: 30` (attributes) is a separate curve not needed by this provider.
const _playerLevelBase = 100;

/// The Today dashboard's Player Header numbers, derived from
/// [totalXpProvider] via the pure [LevelCurve] — no value here is ever
/// persisted or computed any other way.
@riverpod
Future<PlayerLevelSummary> playerLevelSummary(Ref ref) async {
  final totalXp = await ref.watch(totalXpProvider.future);
  const levelCurve = LevelCurve();
  final progress = levelCurve.levelForTotalXp(totalXp, base: _playerLevelBase);
  final currentLevelStartXp = totalXp - progress.currentXpIntoLevel;
  final nextLevelXp = currentLevelStartXp + progress.xpRequiredForNextLevel;
  final progressRatio = progress.xpRequiredForNextLevel == 0
      ? 0.0
      : (progress.currentXpIntoLevel / progress.xpRequiredForNextLevel).clamp(
          0.0,
          1.0,
        );

  return PlayerLevelSummary(
    totalXp: totalXp,
    currentLevel: progress.level,
    currentLevelStartXp: currentLevelStartXp,
    nextLevelXp: nextLevelXp,
    xpIntoCurrentLevel: progress.currentXpIntoLevel,
    xpNeededForNextLevel: progress.xpRequiredForNextLevel,
    progressRatio: progressRatio,
  );
}
