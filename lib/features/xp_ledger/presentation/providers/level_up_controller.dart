import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/services/level_curve.dart';
import '../models/level_up_event.dart';
import 'xp_ledger_providers.dart';

part 'level_up_controller.g.dart';

const _playerLevelBase = 100;
const _levelCurve = LevelCurve();

/// [lastObservedTotalXp] is the session baseline the controller compares
/// every new [totalXpProvider] emission against — `null` only before the
/// very first observation. [pendingEvent] is the not-yet-acknowledged
/// level-up, if any.
class LevelUpControllerState {
  final int? lastObservedTotalXp;
  final LevelUpEvent? pendingEvent;

  const LevelUpControllerState({this.lastObservedTotalXp, this.pendingEvent});

  LevelUpControllerState copyWith({
    int? lastObservedTotalXp,
    LevelUpEvent? pendingEvent,
    bool clearPendingEvent = false,
  }) {
    return LevelUpControllerState(
      lastObservedTotalXp: lastObservedTotalXp ?? this.lastObservedTotalXp,
      pendingEvent: clearPendingEvent
          ? null
          : (pendingEvent ?? this.pendingEvent),
    );
  }
}

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
@Riverpod(keepAlive: true)
class LevelUpController extends _$LevelUpController {
  @override
  LevelUpControllerState build() {
    // A plain, non-subscribing read: this only seeds the initial baseline
    // synchronously, if already available. `ref.listen` below (not `watch`)
    // is what reacts to every later change, without tying this controller's
    // own rebuild lifecycle to the ledger's.
    final initialXp = ref.read(totalXpProvider).value;

    ref.listen<AsyncValue<int>>(totalXpProvider, (previous, next) {
      final newTotalXp = next.value;
      if (newTotalXp == null) return; // still loading, or errored
      _onTotalXpChanged(newTotalXp);
    });

    return LevelUpControllerState(lastObservedTotalXp: initialXp);
  }

  void _onTotalXpChanged(int newTotalXp) {
    final baseline = state.lastObservedTotalXp;
    if (baseline == null) {
      // First observation this session — establish the baseline only.
      state = state.copyWith(lastObservedTotalXp: newTotalXp);
      return;
    }
    if (newTotalXp <= baseline) {
      return; // XP never decreases in this app; an equal re-emission is a no-op.
    }

    final previousLevel = _levelCurve
        .levelForTotalXp(baseline, base: _playerLevelBase)
        .level;
    final newLevel = _levelCurve
        .levelForTotalXp(newTotalXp, base: _playerLevelBase)
        .level;

    if (newLevel <= previousLevel) {
      state = state.copyWith(lastObservedTotalXp: newTotalXp);
      return;
    }

    final existingPending = state.pendingEvent;
    state = LevelUpControllerState(
      lastObservedTotalXp: newTotalXp,
      pendingEvent: LevelUpEvent(
        previousLevel: existingPending?.previousLevel ?? previousLevel,
        newLevel: newLevel,
        previousTotalXp: existingPending?.previousTotalXp ?? baseline,
        newTotalXp: newTotalXp,
        occurredAt: DateTime.now().toUtc(),
      ),
    );
  }

  /// Clears the pending event. Idempotent — calling it with nothing pending
  /// is a no-op, so the shell never has to guard the call site.
  void acknowledge() {
    if (state.pendingEvent == null) return;
    state = state.copyWith(clearPendingEvent: true);
  }
}
