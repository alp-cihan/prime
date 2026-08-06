/// The three choices offered by the Settings language selector. Kept as a
/// plain, Flutter-free enum (no `Locale` reference here) so it can be
/// persisted and reasoned about without pulling `package:flutter` into a
/// storage-adjacent file — [AppLocaleOption.resolvedLocale] in
/// `locale_controller.dart` is the one place that turns this into a real
/// `Locale`.
enum AppLocaleOption {
  /// Follow the device locale, re-resolved live if the device locale ever
  /// changes. This is the default until the user makes an explicit choice.
  system,
  english,
  turkish;

  /// The value written to storage — deliberately independent of the enum's
  /// declaration order (`.name` would silently break persisted data if this
  /// enum were ever reordered).
  String get storageKey => switch (this) {
    AppLocaleOption.system => 'system',
    AppLocaleOption.english => 'en',
    AppLocaleOption.turkish => 'tr',
  };

  static AppLocaleOption fromStorageKey(String? key) => switch (key) {
    'en' => AppLocaleOption.english,
    'tr' => AppLocaleOption.turkish,
    _ => AppLocaleOption.system,
  };
}
