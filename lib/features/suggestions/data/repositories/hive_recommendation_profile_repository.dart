import 'package:hive_ce/hive.dart';

import '../../domain/entities/recommendation_profile.dart';
import '../../domain/repositories/recommendation_profile_repository.dart';
import '../mappers/recommendation_profile_mapper.dart';
import '../models/recommendation_profile_hive_model.dart';

/// A single record under a fixed key — there is only ever one
/// recommendation profile per device, same "singleton row in a typed box"
/// shape as every other feature's data would need if it only ever persisted
/// one thing (no other feature does yet, so there is no existing precedent
/// to match beyond `QuestMapper`'s general enum-as-name convention).
class HiveRecommendationProfileRepository
    implements RecommendationProfileRepository {
  HiveRecommendationProfileRepository(
    this._box, {
    RecommendationProfileMapper mapper = const RecommendationProfileMapper(),
  }) : _mapper = mapper;

  final Box<RecommendationProfileHiveModel> _box;
  final RecommendationProfileMapper _mapper;

  static const _key = 'profile';

  @override
  Future<RecommendationProfile> get() async {
    final model = _box.get(_key);
    if (model == null) return RecommendationProfile.defaultProfile;
    return _mapper.toDomain(model);
  }

  @override
  Future<void> save(RecommendationProfile profile) async {
    await _box.put(_key, _mapper.toModel(profile));
  }

  @override
  Future<void> markSuggestionAccepted(String suggestionId) async {
    final current = await get();
    if (current.acceptedSuggestionIds.contains(suggestionId)) return;
    await save(
      current.copyWith(
        acceptedSuggestionIds: {...current.acceptedSuggestionIds, suggestionId},
      ),
    );
  }
}
