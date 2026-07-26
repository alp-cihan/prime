/// A one-off unlock attached to a [Quest], per docs/architecture.md §15.
/// `titleId`/`achievementId` are inert until Phases 2's Titles/Achievements
/// systems exist to grant them.
class Reward {
  final int? xp;
  final String? titleId;
  final String? achievementId;

  const Reward({this.xp, this.titleId, this.achievementId});

  Reward copyWith({int? xp, String? titleId, String? achievementId}) {
    return Reward(
      xp: xp ?? this.xp,
      titleId: titleId ?? this.titleId,
      achievementId: achievementId ?? this.achievementId,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Reward &&
      other.xp == xp &&
      other.titleId == titleId &&
      other.achievementId == achievementId;

  @override
  int get hashCode => Object.hash(xp, titleId, achievementId);
}
