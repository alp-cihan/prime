import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/localization/app_locale_option.dart';
import 'package:prime/core/localization/locale_controller.dart';

void main() {
  group('storageKey / fromStorageKey round-trip', () {
    test('every option round-trips through its storage key', () {
      for (final option in AppLocaleOption.values) {
        expect(AppLocaleOption.fromStorageKey(option.storageKey), option);
      }
    });

    test('storage keys are independent of declaration order', () {
      expect(AppLocaleOption.system.storageKey, 'system');
      expect(AppLocaleOption.english.storageKey, 'en');
      expect(AppLocaleOption.turkish.storageKey, 'tr');
    });

    test('an unrecognized or null stored key falls back to system', () {
      expect(AppLocaleOption.fromStorageKey(null), AppLocaleOption.system);
      expect(AppLocaleOption.fromStorageKey('fr'), AppLocaleOption.system);
      expect(AppLocaleOption.fromStorageKey(''), AppLocaleOption.system);
    });
  });

  group('resolvedLocale', () {
    test('system resolves to null, letting MaterialApp auto-resolve', () {
      expect(AppLocaleOption.system.resolvedLocale, isNull);
    });

    test('english resolves to Locale("en")', () {
      expect(AppLocaleOption.english.resolvedLocale, const Locale('en'));
    });

    test('turkish resolves to Locale("tr")', () {
      expect(AppLocaleOption.turkish.resolvedLocale, const Locale('tr'));
    });
  });
}
