import 'package:hive_ce/hive.dart';

import '../../../../core/persistence/hive_type_ids.dart';

part 'recommendation_profile_hive_model.g.dart';

/// Persisted shape of a [RecommendationProfile]. A single record, stored
/// under a fixed key (see `HiveRecommendationProfileRepository`) — there is
/// only ever one profile per device.
///
/// Field index map — **never reuse or renumber**:
/// ```text
///  0 lifeStage
///  1 goals
///  2 availableTime
///  3 intensity
///  4 isPersonalized
///  5 acceptedSuggestionIds
/// ```
/// Next available index: 6.
@HiveType(typeId: HiveTypeIds.recommendationProfile)
class RecommendationProfileHiveModel {
  @HiveField(0)
  final String lifeStage;
  @HiveField(1)
  final List<String> goals;
  @HiveField(2)
  final String availableTime;
  @HiveField(3)
  final String intensity;
  @HiveField(4)
  final bool isPersonalized;
  @HiveField(5)
  final List<String> acceptedSuggestionIds;

  RecommendationProfileHiveModel({
    required this.lifeStage,
    required this.goals,
    required this.availableTime,
    required this.intensity,
    required this.isPersonalized,
    required this.acceptedSuggestionIds,
  });
}
