import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/xp_ledger/presentation/providers/level_up_controller.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

/// A directly-controllable stand-in for the ledger-derived [totalXpProvider]
/// — lets these tests drive exact XP sequences (including same-value
/// re-emissions) without needing a real Hive-backed ledger, and without
/// being limited to the ledger's real append-only (monotonic) writes.
final _xpHolderProvider = StateProvider<int>((ref) => 0);

ProviderContainer _buildContainer({int initialXp = 0}) {
  final container = ProviderContainer(
    overrides: [
      totalXpProvider.overrideWith((ref) async => ref.watch(_xpHolderProvider)),
    ],
  );
  container.read(_xpHolderProvider.notifier).state = initialXp;
  return container;
}

Future<void> _waitFor(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met within 2 seconds');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  test(
    'initial total XP load emits no event, even from an already-elevated account',
    () async {
      final container = _buildContainer(initialXp: 5000);
      addTearDown(container.dispose);

      await container.read(totalXpProvider.future);
      final state = container.read(levelUpControllerProvider);

      expect(state.pendingEvent, isNull);
      expect(state.lastObservedTotalXp, 5000);
    },
  );

  test('the same XP value emitted again produces no event', () async {
    final container = _buildContainer(initialXp: 100);
    addTearDown(container.dispose);
    await container.read(totalXpProvider.future);
    container.read(levelUpControllerProvider); // establish baseline

    container.read(_xpHolderProvider.notifier).state = 100; // no-op change
    await container.read(totalXpProvider.future);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(container.read(levelUpControllerProvider).pendingEvent, isNull);
  });

  test(
    'a lower XP value produces no event (XP never decreases, but is defensively ignored)',
    () async {
      final container = _buildContainer(initialXp: 500);
      addTearDown(container.dispose);
      await container.read(totalXpProvider.future);
      container.read(levelUpControllerProvider);

      container.read(_xpHolderProvider.notifier).state = 100;
      await container.read(totalXpProvider.future);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(container.read(levelUpControllerProvider).pendingEvent, isNull);
    },
  );

  test(
    'crossing exactly one level emits one event with the correct levels',
    () async {
      final container = _buildContainer(initialXp: 90);
      addTearDown(container.dispose);
      await container.read(totalXpProvider.future);
      container.read(levelUpControllerProvider);

      container.read(_xpHolderProvider.notifier).state =
          150; // crosses 100 (L1->L2)
      await container.read(totalXpProvider.future);
      await _waitFor(
        () => container.read(levelUpControllerProvider).pendingEvent != null,
      );

      final event = container.read(levelUpControllerProvider).pendingEvent!;
      expect(event.previousLevel, 1);
      expect(event.newLevel, 2);
      expect(event.previousTotalXp, 90);
      expect(event.newTotalXp, 150);
    },
  );

  test(
    'crossing multiple levels in one change preserves both endpoints',
    () async {
      // Level 2 starts at 100, level 3 at 100+282=382, level 4 at 382+520=902.
      final container = _buildContainer(initialXp: 90);
      addTearDown(container.dispose);
      await container.read(totalXpProvider.future);
      container.read(levelUpControllerProvider);

      container.read(_xpHolderProvider.notifier).state = 1000; // L1 -> L4
      await container.read(totalXpProvider.future);
      await _waitFor(
        () => container.read(levelUpControllerProvider).pendingEvent != null,
      );

      final event = container.read(levelUpControllerProvider).pendingEvent!;
      expect(event.previousLevel, 1);
      expect(event.newLevel, 4);
    },
  );

  test(
    'a duplicate provider emission does not duplicate/replace an already-pending event',
    () async {
      final container = _buildContainer(initialXp: 90);
      addTearDown(container.dispose);
      await container.read(totalXpProvider.future);
      container.read(levelUpControllerProvider);

      container.read(_xpHolderProvider.notifier).state = 150;
      await container.read(totalXpProvider.future);
      await _waitFor(
        () => container.read(levelUpControllerProvider).pendingEvent != null,
      );
      final firstEvent = container.read(levelUpControllerProvider).pendingEvent;

      // Re-emitting the exact same value must not fabricate a second event.
      container.read(_xpHolderProvider.notifier).state = 150;
      await container.read(totalXpProvider.future);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        container.read(levelUpControllerProvider).pendingEvent,
        firstEvent,
      );
    },
  );

  test(
    'a second crossing before acknowledgement widens rather than replaces the pending event',
    () async {
      final container = _buildContainer(initialXp: 90);
      addTearDown(container.dispose);
      await container.read(totalXpProvider.future);
      container.read(levelUpControllerProvider);

      container.read(_xpHolderProvider.notifier).state = 150; // L1 -> L2
      await container.read(totalXpProvider.future);
      await _waitFor(
        () => container.read(levelUpControllerProvider).pendingEvent != null,
      );

      container.read(_xpHolderProvider.notifier).state =
          500; // L2 -> L3, unacknowledged
      await container.read(totalXpProvider.future);
      await _waitFor(
        () =>
            container.read(levelUpControllerProvider).pendingEvent!.newLevel ==
            3,
      );

      final event = container.read(levelUpControllerProvider).pendingEvent!;
      expect(event.previousLevel, 1); // preserved from the first crossing
      expect(event.newLevel, 3);
      expect(event.previousTotalXp, 90);
      expect(event.newTotalXp, 500);
    },
  );

  test('acknowledge clears the pending event', () async {
    final container = _buildContainer(initialXp: 90);
    addTearDown(container.dispose);
    await container.read(totalXpProvider.future);
    container.read(levelUpControllerProvider);

    container.read(_xpHolderProvider.notifier).state = 150;
    await container.read(totalXpProvider.future);
    await _waitFor(
      () => container.read(levelUpControllerProvider).pendingEvent != null,
    );

    container.read(levelUpControllerProvider.notifier).acknowledge();

    expect(container.read(levelUpControllerProvider).pendingEvent, isNull);
  });

  test('after acknowledge, a later level-up can emit again', () async {
    final container = _buildContainer(initialXp: 90);
    addTearDown(container.dispose);
    await container.read(totalXpProvider.future);
    container.read(levelUpControllerProvider);

    container.read(_xpHolderProvider.notifier).state = 150;
    await container.read(totalXpProvider.future);
    await _waitFor(
      () => container.read(levelUpControllerProvider).pendingEvent != null,
    );
    container.read(levelUpControllerProvider.notifier).acknowledge();
    expect(container.read(levelUpControllerProvider).pendingEvent, isNull);

    container.read(_xpHolderProvider.notifier).state = 500; // L2 -> L3
    await container.read(totalXpProvider.future);
    await _waitFor(
      () => container.read(levelUpControllerProvider).pendingEvent != null,
    );

    final event = container.read(levelUpControllerProvider).pendingEvent!;
    expect(event.previousLevel, 2);
    expect(event.newLevel, 3);
  });
}
