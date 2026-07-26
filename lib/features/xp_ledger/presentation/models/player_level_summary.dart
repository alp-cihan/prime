/// The Today dashboard's Player Header (docs/architecture.md §13.1), derived
/// entirely from [LevelCurve] + the ledger's lifetime total — never a
/// separately-persisted level or progress value (CLAUDE.md: "Cached XP
/// totals are projections, not the source of truth").
class PlayerLevelSummary {
  final int totalXp;
  final int currentLevel;
  final int currentLevelStartXp;
  final int nextLevelXp;
  final int xpIntoCurrentLevel;
  final int xpNeededForNextLevel;
  final double progressRatio;

  const PlayerLevelSummary({
    required this.totalXp,
    required this.currentLevel,
    required this.currentLevelStartXp,
    required this.nextLevelXp,
    required this.xpIntoCurrentLevel,
    required this.xpNeededForNextLevel,
    required this.progressRatio,
  });

  @override
  bool operator ==(Object other) =>
      other is PlayerLevelSummary &&
      other.totalXp == totalXp &&
      other.currentLevel == currentLevel &&
      other.currentLevelStartXp == currentLevelStartXp &&
      other.nextLevelXp == nextLevelXp &&
      other.xpIntoCurrentLevel == xpIntoCurrentLevel &&
      other.xpNeededForNextLevel == xpNeededForNextLevel &&
      other.progressRatio == progressRatio;

  @override
  int get hashCode => Object.hash(
    totalXp,
    currentLevel,
    currentLevelStartXp,
    nextLevelXp,
    xpIntoCurrentLevel,
    xpNeededForNextLevel,
    progressRatio,
  );
}
