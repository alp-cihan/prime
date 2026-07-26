// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_up_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Detects a global-level crossing from [totalXpProvider] changes and holds
/// at most one pending [LevelUpEvent] for the shell to present (docs/
/// architecture.md §14).
///
/// ## Initial-load rule
/// The first total XP this controller ever observes — whether the ledger is
/// empty or the account already has years of XP — only establishes the
/// session baseline. It can never itself produce a [LevelUpEvent]: there is
/// no "previous" observation to have crossed a threshold from. This is why
/// the baseline is captured via [_onTotalXpChanged]'s own null-baseline
/// branch rather than by seeding it from level 1 — an account restored at,
/// say, level 40 must not immediately fire 39 level-up celebrations.
///
/// ## Multi-level jumps
/// A single XP change (e.g. a big quest awarding enough XP to cross more
/// than one level threshold) is captured as one event spanning
/// [LevelUpEvent.previousLevel] to [LevelUpEvent.newLevel] — never
/// flattened into a single generic "leveled up" boolean.
///
/// ## Merging while unacknowledged
/// If a second crossing happens before the UI acknowledges the first, the
/// pending event is *widened* (its original `previousLevel`/`previousTotalXp`
/// is preserved, only `newLevel`/`newTotalXp` advance) rather than replaced —
/// so the overlay always reflects the full jump since the last
/// acknowledgement, never silently drops part of it.

@ProviderFor(LevelUpController)
final levelUpControllerProvider = LevelUpControllerProvider._();

/// Detects a global-level crossing from [totalXpProvider] changes and holds
/// at most one pending [LevelUpEvent] for the shell to present (docs/
/// architecture.md §14).
///
/// ## Initial-load rule
/// The first total XP this controller ever observes — whether the ledger is
/// empty or the account already has years of XP — only establishes the
/// session baseline. It can never itself produce a [LevelUpEvent]: there is
/// no "previous" observation to have crossed a threshold from. This is why
/// the baseline is captured via [_onTotalXpChanged]'s own null-baseline
/// branch rather than by seeding it from level 1 — an account restored at,
/// say, level 40 must not immediately fire 39 level-up celebrations.
///
/// ## Multi-level jumps
/// A single XP change (e.g. a big quest awarding enough XP to cross more
/// than one level threshold) is captured as one event spanning
/// [LevelUpEvent.previousLevel] to [LevelUpEvent.newLevel] — never
/// flattened into a single generic "leveled up" boolean.
///
/// ## Merging while unacknowledged
/// If a second crossing happens before the UI acknowledges the first, the
/// pending event is *widened* (its original `previousLevel`/`previousTotalXp`
/// is preserved, only `newLevel`/`newTotalXp` advance) rather than replaced —
/// so the overlay always reflects the full jump since the last
/// acknowledgement, never silently drops part of it.
final class LevelUpControllerProvider
    extends $NotifierProvider<LevelUpController, LevelUpControllerState> {
  /// Detects a global-level crossing from [totalXpProvider] changes and holds
  /// at most one pending [LevelUpEvent] for the shell to present (docs/
  /// architecture.md §14).
  ///
  /// ## Initial-load rule
  /// The first total XP this controller ever observes — whether the ledger is
  /// empty or the account already has years of XP — only establishes the
  /// session baseline. It can never itself produce a [LevelUpEvent]: there is
  /// no "previous" observation to have crossed a threshold from. This is why
  /// the baseline is captured via [_onTotalXpChanged]'s own null-baseline
  /// branch rather than by seeding it from level 1 — an account restored at,
  /// say, level 40 must not immediately fire 39 level-up celebrations.
  ///
  /// ## Multi-level jumps
  /// A single XP change (e.g. a big quest awarding enough XP to cross more
  /// than one level threshold) is captured as one event spanning
  /// [LevelUpEvent.previousLevel] to [LevelUpEvent.newLevel] — never
  /// flattened into a single generic "leveled up" boolean.
  ///
  /// ## Merging while unacknowledged
  /// If a second crossing happens before the UI acknowledges the first, the
  /// pending event is *widened* (its original `previousLevel`/`previousTotalXp`
  /// is preserved, only `newLevel`/`newTotalXp` advance) rather than replaced —
  /// so the overlay always reflects the full jump since the last
  /// acknowledgement, never silently drops part of it.
  LevelUpControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'levelUpControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$levelUpControllerHash();

  @$internal
  @override
  LevelUpController create() => LevelUpController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LevelUpControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LevelUpControllerState>(value),
    );
  }
}

String _$levelUpControllerHash() => r'5391ab6268ed3a9710c84243a9d3a99ce46f909f';

/// Detects a global-level crossing from [totalXpProvider] changes and holds
/// at most one pending [LevelUpEvent] for the shell to present (docs/
/// architecture.md §14).
///
/// ## Initial-load rule
/// The first total XP this controller ever observes — whether the ledger is
/// empty or the account already has years of XP — only establishes the
/// session baseline. It can never itself produce a [LevelUpEvent]: there is
/// no "previous" observation to have crossed a threshold from. This is why
/// the baseline is captured via [_onTotalXpChanged]'s own null-baseline
/// branch rather than by seeding it from level 1 — an account restored at,
/// say, level 40 must not immediately fire 39 level-up celebrations.
///
/// ## Multi-level jumps
/// A single XP change (e.g. a big quest awarding enough XP to cross more
/// than one level threshold) is captured as one event spanning
/// [LevelUpEvent.previousLevel] to [LevelUpEvent.newLevel] — never
/// flattened into a single generic "leveled up" boolean.
///
/// ## Merging while unacknowledged
/// If a second crossing happens before the UI acknowledges the first, the
/// pending event is *widened* (its original `previousLevel`/`previousTotalXp`
/// is preserved, only `newLevel`/`newTotalXp` advance) rather than replaced —
/// so the overlay always reflects the full jump since the last
/// acknowledgement, never silently drops part of it.

abstract class _$LevelUpController extends $Notifier<LevelUpControllerState> {
  LevelUpControllerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<LevelUpControllerState, LevelUpControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LevelUpControllerState, LevelUpControllerState>,
              LevelUpControllerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
