// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_query_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits the current unlock history immediately, then again on every
/// subsequent change (`HiveAchievementUnlockRepository.watchAll`'s
/// `Box.watch()`-backed contract) — every widget watching this shares one
/// underlying subscription, same pattern as `watchAllQuestsProvider`.

@ProviderFor(watchAchievementUnlocks)
final watchAchievementUnlocksProvider = WatchAchievementUnlocksProvider._();

/// Emits the current unlock history immediately, then again on every
/// subsequent change (`HiveAchievementUnlockRepository.watchAll`'s
/// `Box.watch()`-backed contract) — every widget watching this shares one
/// underlying subscription, same pattern as `watchAllQuestsProvider`.

final class WatchAchievementUnlocksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AchievementUnlock>>,
          List<AchievementUnlock>,
          Stream<List<AchievementUnlock>>
        >
    with
        $FutureModifier<List<AchievementUnlock>>,
        $StreamProvider<List<AchievementUnlock>> {
  /// Emits the current unlock history immediately, then again on every
  /// subsequent change (`HiveAchievementUnlockRepository.watchAll`'s
  /// `Box.watch()`-backed contract) — every widget watching this shares one
  /// underlying subscription, same pattern as `watchAllQuestsProvider`.
  WatchAchievementUnlocksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAchievementUnlocksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAchievementUnlocksHash();

  @$internal
  @override
  $StreamProviderElement<List<AchievementUnlock>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AchievementUnlock>> create(Ref ref) {
    return watchAchievementUnlocks(ref);
  }
}

String _$watchAchievementUnlocksHash() =>
    r'b9568a20dd6f20ca3835d8af0c340b890b060001';

/// Unlocked achievements, sorted most-recently-unlocked first — the
/// Achievements page's "Unlocked" section.

@ProviderFor(unlockedAchievements)
final unlockedAchievementsProvider = UnlockedAchievementsProvider._();

/// Unlocked achievements, sorted most-recently-unlocked first — the
/// Achievements page's "Unlocked" section.

final class UnlockedAchievementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UnlockedAchievement>>,
          List<UnlockedAchievement>,
          FutureOr<List<UnlockedAchievement>>
        >
    with
        $FutureModifier<List<UnlockedAchievement>>,
        $FutureProvider<List<UnlockedAchievement>> {
  /// Unlocked achievements, sorted most-recently-unlocked first — the
  /// Achievements page's "Unlocked" section.
  UnlockedAchievementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlockedAchievementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unlockedAchievementsHash();

  @$internal
  @override
  $FutureProviderElement<List<UnlockedAchievement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UnlockedAchievement>> create(Ref ref) {
    return unlockedAchievements(ref);
  }
}

String _$unlockedAchievementsHash() =>
    r'286221714ef1167d714ac543d04f4095aca785b7';

/// Locked achievements with their current progress ratio — the Achievements
/// page's "Locked" section. Progress is derived from a fresh criteria
/// snapshot every time this provider recomputes (no separate cached
/// progress value exists anywhere).

@ProviderFor(lockedAchievements)
final lockedAchievementsProvider = LockedAchievementsProvider._();

/// Locked achievements with their current progress ratio — the Achievements
/// page's "Locked" section. Progress is derived from a fresh criteria
/// snapshot every time this provider recomputes (no separate cached
/// progress value exists anywhere).

final class LockedAchievementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LockedAchievementProgress>>,
          List<LockedAchievementProgress>,
          FutureOr<List<LockedAchievementProgress>>
        >
    with
        $FutureModifier<List<LockedAchievementProgress>>,
        $FutureProvider<List<LockedAchievementProgress>> {
  /// Locked achievements with their current progress ratio — the Achievements
  /// page's "Locked" section. Progress is derived from a fresh criteria
  /// snapshot every time this provider recomputes (no separate cached
  /// progress value exists anywhere).
  LockedAchievementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockedAchievementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockedAchievementsHash();

  @$internal
  @override
  $FutureProviderElement<List<LockedAchievementProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LockedAchievementProgress>> create(Ref ref) {
    return lockedAchievements(ref);
  }
}

String _$lockedAchievementsHash() =>
    r'1c02e7fd37a401548d96c5ff1b8e6aeb7cda492a';

/// Total achievement count — unlocked + locked always sum to this, since
/// every catalog entry is exactly one or the other.

@ProviderFor(achievementCatalogCount)
final achievementCatalogCountProvider = AchievementCatalogCountProvider._();

/// Total achievement count — unlocked + locked always sum to this, since
/// every catalog entry is exactly one or the other.

final class AchievementCatalogCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Total achievement count — unlocked + locked always sum to this, since
  /// every catalog entry is exactly one or the other.
  AchievementCatalogCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementCatalogCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementCatalogCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return achievementCatalogCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$achievementCatalogCountHash() =>
    r'7d21016a54d2551f6bc255e0ce55597de4f6baaa';
