import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/persistence_providers.dart';
import 'app_locale_option.dart';
import 'hive_locale_repository.dart';
import 'locale_repository.dart';

part 'locale_controller.g.dart';

@Riverpod(keepAlive: true)
LocaleRepository localeRepository(Ref ref) {
  return HiveLocaleRepository(ref.watch(localePreferenceHiveBoxProvider));
}

/// The user's current language choice — read synchronously from Hive at
/// construction (mirrors `OnboardingRepository`'s "no loading state" design;
/// see that repository's own doc for why) so `MaterialApp.router`'s
/// `locale:` can watch this directly with no splash/loading gap, and so
/// changing it updates the UI live without a restart.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  AppLocaleOption build() => ref.watch(localeRepositoryProvider).getOption();

  void setOption(AppLocaleOption option) {
    ref.read(localeRepositoryProvider).setOption(option);
    state = option;
  }
}

/// `null` lets `MaterialApp.router`'s own locale-resolution algorithm pick
/// from the device's locales against `supportedLocales` — exactly System
/// mode's behavior (device locale if supported, otherwise the first
/// `supportedLocales` entry), with no fallback logic duplicated here.
extension AppLocaleOptionLocale on AppLocaleOption {
  Locale? get resolvedLocale => switch (this) {
    AppLocaleOption.system => null,
    AppLocaleOption.english => const Locale('en'),
    AppLocaleOption.turkish => const Locale('tr'),
  };
}
