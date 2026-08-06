import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/localization/app_locale_option.dart';
import 'package:prime/core/localization/locale_controller.dart';
import 'package:prime/core/localization/locale_repository.dart';

class _FakeLocaleRepository implements LocaleRepository {
  _FakeLocaleRepository({AppLocaleOption initial = AppLocaleOption.system})
    : _option = initial;

  AppLocaleOption _option;
  int setOptionCallCount = 0;

  @override
  AppLocaleOption getOption() => _option;

  @override
  void setOption(AppLocaleOption option) {
    setOptionCallCount++;
    _option = option;
  }
}

ProviderContainer _buildContainer(_FakeLocaleRepository repository) {
  return ProviderContainer(
    overrides: [localeRepositoryProvider.overrideWithValue(repository)],
  );
}

void main() {
  test('builds from whatever the repository currently has stored', () {
    final repository = _FakeLocaleRepository(initial: AppLocaleOption.turkish);
    final container = _buildContainer(repository);
    addTearDown(container.dispose);

    expect(container.read(localeControllerProvider), AppLocaleOption.turkish);
  });

  test('defaults to system for a fresh install', () {
    final container = _buildContainer(_FakeLocaleRepository());
    addTearDown(container.dispose);

    expect(container.read(localeControllerProvider), AppLocaleOption.system);
  });

  test(
    'setOption updates state synchronously and persists through the repository',
    () {
      final repository = _FakeLocaleRepository();
      final container = _buildContainer(repository);
      addTearDown(container.dispose);

      container
          .read(localeControllerProvider.notifier)
          .setOption(AppLocaleOption.english);

      expect(container.read(localeControllerProvider), AppLocaleOption.english);
      expect(repository.getOption(), AppLocaleOption.english);
      expect(repository.setOptionCallCount, 1);
    },
  );

  test('switching back to system after an explicit choice works', () {
    final repository = _FakeLocaleRepository(initial: AppLocaleOption.turkish);
    final container = _buildContainer(repository);
    addTearDown(container.dispose);

    container
        .read(localeControllerProvider.notifier)
        .setOption(AppLocaleOption.system);

    expect(container.read(localeControllerProvider), AppLocaleOption.system);
    expect(repository.getOption(), AppLocaleOption.system);
  });
}
