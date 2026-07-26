import 'dart:math';

/// A player's or attribute's derived standing at a given lifetime XP total.
class LevelProgress {
  final int level;
  final int currentXpIntoLevel;
  final int xpRequiredForNextLevel;

  const LevelProgress({
    required this.level,
    required this.currentXpIntoLevel,
    required this.xpRequiredForNextLevel,
  });

  @override
  bool operator ==(Object other) =>
      other is LevelProgress &&
      other.level == level &&
      other.currentXpIntoLevel == currentXpIntoLevel &&
      other.xpRequiredForNextLevel == xpRequiredForNextLevel;

  @override
  int get hashCode =>
      Object.hash(level, currentXpIntoLevel, xpRequiredForNextLevel);
}

/// docs/architecture.md §4 — the sub-exponential level curve shared by the
/// global player level (`base: 100`) and each attribute (`base: 30`).
///
/// All methods enforce `base > 0` and `level >= 1` as programmer contracts
/// (via [ArgumentError], not [Result]) — a non-positive `base` would make
/// `xpToNext` return 0 forever, which would make [levelForTotalXp]'s search
/// loop non-terminating for any positive `totalXp`.
class LevelCurve {
  const LevelCurve();

  /// `xpToNext(n) = floor(base * n^1.5)`.
  int xpToNext(int level, {required int base}) {
    _checkBase(base);
    _checkLevel(level);
    return (base * pow(level, 1.5)).floor();
  }

  /// Total XP required to have already reached [level] (i.e. the sum of
  /// `xpToNext` for every level below it).
  int cumulativeXpForLevel(int level, {required int base}) {
    _checkBase(base);
    _checkLevel(level);
    var total = 0;
    for (var n = 1; n < level; n++) {
      total += xpToNext(n, base: base);
    }
    return total;
  }

  /// Derives the level and progress-into-level for a given lifetime XP total.
  ///
  /// Termination is guaranteed by the [_checkBase] contract: with `base > 0`,
  /// `xpToNext` is always at least 1, so `cumulative` strictly increases
  /// every iteration and must eventually exceed any finite, non-negative
  /// `totalXp`.
  LevelProgress levelForTotalXp(int totalXp, {required int base}) {
    _checkBase(base);
    if (totalXp < 0) {
      throw ArgumentError.value(totalXp, 'totalXp', 'must not be negative');
    }

    var level = 1;
    var cumulative = 0;
    while (true) {
      final next = xpToNext(level, base: base);
      if (cumulative + next > totalXp) {
        return LevelProgress(
          level: level,
          currentXpIntoLevel: totalXp - cumulative,
          xpRequiredForNextLevel: next,
        );
      }
      cumulative += next;
      level++;
    }
  }

  void _checkBase(int base) {
    if (base <= 0) {
      throw ArgumentError.value(base, 'base', 'must be greater than zero');
    }
  }

  void _checkLevel(int level) {
    if (level < 1) {
      throw ArgumentError.value(level, 'level', 'must be at least 1');
    }
  }
}
