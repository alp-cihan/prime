import 'package:hive_ce/hive.dart';

import 'app_locale_option.dart';
import 'locale_repository.dart';

/// A single string flag in its own tiny box — same pattern as
/// `HiveOnboardingRepository`, not worth a `@HiveType` model for one field.
class HiveLocaleRepository implements LocaleRepository {
  const HiveLocaleRepository(this._box);

  final Box<String> _box;

  static const _optionKey = 'locale_option';

  @override
  AppLocaleOption getOption() =>
      AppLocaleOption.fromStorageKey(_box.get(_optionKey));

  @override
  void setOption(AppLocaleOption option) =>
      _box.put(_optionKey, option.storageKey);
}
