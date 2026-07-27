import 'package:hive_ce/hive.dart';

import '../../domain/repositories/onboarding_repository.dart';

/// A single boolean flag in its own tiny box — not worth a `@HiveType` model
/// for one field, unlike every other persisted entity in this app.
class HiveOnboardingRepository implements OnboardingRepository {
  const HiveOnboardingRepository(this._box);

  final Box<bool> _box;

  static const _completedKey = 'onboarding_completed';

  @override
  bool isCompleted() => _box.get(_completedKey, defaultValue: false) ?? false;

  @override
  void markCompleted() => _box.put(_completedKey, true);

  @override
  void reset() => _box.put(_completedKey, false);
}
