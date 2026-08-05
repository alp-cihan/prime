import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';
import 'package:prime/features/suggestions/presentation/providers/recommendation_profile_controller.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  test('loads the default profile for a fresh install', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    final profile = await container.read(
      recommendationProfileControllerProvider.future,
    );

    expect(profile, RecommendationProfile.defaultProfile);
  });

  test('idle -> loading -> success on save, and the new value is readable '
      'immediately after', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(recommendationProfileControllerProvider.future);

    final states = <AsyncValue<RecommendationProfile>>[];
    final subscription = container.listen(
      recommendationProfileControllerProvider,
      (previous, next) => states.add(next),
    );
    addTearDown(subscription.close);

    final edited = RecommendationProfile.defaultProfile.copyWith(
      lifeStage: LifeStage.student,
      goals: {GoalArea.study},
    );
    await container
        .read(recommendationProfileControllerProvider.notifier)
        .save(edited);

    expect(states.any((s) => s.isLoading), isTrue);
    final saved = container
        .read(recommendationProfileControllerProvider)
        .value!;
    expect(saved.lifeStage, LifeStage.student);
    expect(saved.goals, {GoalArea.study});
    expect(saved.isPersonalized, isTrue);
  });

  test('a second concurrent save while one is in flight is a no-op', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(recommendationProfileControllerProvider.future);
    final notifier = container.read(
      recommendationProfileControllerProvider.notifier,
    );

    final first = notifier.save(
      RecommendationProfile.defaultProfile.copyWith(
        lifeStage: LifeStage.student,
      ),
    );
    final second = notifier.save(
      RecommendationProfile.defaultProfile.copyWith(
        lifeStage: LifeStage.retired,
      ),
    );
    await first;
    await second;

    // The second call's guard (`state.isLoading`) fires before the first
    // save's write lands, so only the first save's value should stick.
    final result = container
        .read(recommendationProfileControllerProvider)
        .value!;
    expect(result.lifeStage, LifeStage.student);
  });

  test('a saved profile survives a full app restart', () async {
    var container = await buildTestContainer();
    await container.read(recommendationProfileControllerProvider.future);
    final edited = RecommendationProfile.defaultProfile.copyWith(
      lifeStage: LifeStage.entrepreneur,
      goals: {GoalArea.finance, GoalArea.career},
      availableTime: AvailableTime.over60,
      intensity: PreferredIntensity.challenging,
    );
    await container
        .read(recommendationProfileControllerProvider.notifier)
        .save(edited);
    container.dispose();

    await support.reopen();
    container = await buildTestContainer();
    addTearDown(container.dispose);

    final reloaded = await container.read(
      recommendationProfileControllerProvider.future,
    );
    expect(reloaded.lifeStage, LifeStage.entrepreneur);
    expect(reloaded.goals, {GoalArea.finance, GoalArea.career});
    expect(reloaded.availableTime, AvailableTime.over60);
    expect(reloaded.intensity, PreferredIntensity.challenging);
    expect(reloaded.isPersonalized, isTrue);
  });
}
