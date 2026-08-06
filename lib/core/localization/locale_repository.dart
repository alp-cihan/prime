import 'app_locale_option.dart';

/// Local-only "which language did the user pick" preference. Every method is
/// synchronous — same rationale as `OnboardingRepository`: the underlying
/// storage is a raw Hive `Box<String>`, and reads/writes never actually await
/// once the box is open (see `HiveLocaleRepository`).
abstract interface class LocaleRepository {
  AppLocaleOption getOption();

  void setOption(AppLocaleOption option);
}
