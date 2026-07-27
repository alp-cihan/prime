import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/onboarding/data/repositories/hive_onboarding_repository.dart';

import '../../../support/hive_test_support.dart';

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  test('defaults to not completed for a fresh install', () async {
    final box = await Hive.openBox<bool>(HiveBoxNames.appPreferences);
    final repository = HiveOnboardingRepository(box);

    expect(repository.isCompleted(), isFalse);
  });

  test('markCompleted persists across a restart', () async {
    final box = await Hive.openBox<bool>(HiveBoxNames.appPreferences);
    HiveOnboardingRepository(box).markCompleted();

    await support.reopen();
    final reopened = await Hive.openBox<bool>(HiveBoxNames.appPreferences);
    expect(HiveOnboardingRepository(reopened).isCompleted(), isTrue);
  });

  test('reset returns to not-completed', () async {
    final box = await Hive.openBox<bool>(HiveBoxNames.appPreferences);
    final repository = HiveOnboardingRepository(box);

    repository.markCompleted();
    expect(repository.isCompleted(), isTrue);

    repository.reset();
    expect(repository.isCompleted(), isFalse);
  });
}
