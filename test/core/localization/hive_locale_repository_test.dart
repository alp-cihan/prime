import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/localization/app_locale_option.dart';
import 'package:prime/core/localization/hive_locale_repository.dart';
import 'package:prime/core/persistence/hive_box_names.dart';

import '../../support/hive_test_support.dart';

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  test('defaults to system for a fresh install', () async {
    final box = await Hive.openBox<String>(HiveBoxNames.localePreference);
    final repository = HiveLocaleRepository(box);

    expect(repository.getOption(), AppLocaleOption.system);
  });

  test('setOption persists across a restart', () async {
    final box = await Hive.openBox<String>(HiveBoxNames.localePreference);
    HiveLocaleRepository(box).setOption(AppLocaleOption.turkish);

    await support.reopen();
    final reopened = await Hive.openBox<String>(HiveBoxNames.localePreference);
    expect(HiveLocaleRepository(reopened).getOption(), AppLocaleOption.turkish);
  });

  test(
    'switching back to system after an explicit choice persists too',
    () async {
      final box = await Hive.openBox<String>(HiveBoxNames.localePreference);
      final repository = HiveLocaleRepository(box);

      repository.setOption(AppLocaleOption.english);
      expect(repository.getOption(), AppLocaleOption.english);

      repository.setOption(AppLocaleOption.system);
      expect(repository.getOption(), AppLocaleOption.system);
    },
  );
}
