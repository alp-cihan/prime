import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/core/app_info.dart';
import 'package:prime/core/app_restart_scope.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/features/settings/presentation/providers/clear_data_controller.dart';
import 'package:prime/features/settings/presentation/settings_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

/// A test double for [ClearDataController] that never touches real Hive —
/// `ClearLocalDataUseCase`'s own actual box-clearing mechanics are already
/// covered directly (real Hive, no widget tree) by
/// `clear_local_data_use_case_test.dart`; this lets `SettingsPage`'s own
/// confirm/loading/success/error UI behavior be tested in isolation.
class _FakeClearDataController extends ClearDataController {
  bool shouldFail = false;
  int clearCallCount = 0;

  @override
  FutureOr<bool> build() => false;

  @override
  Future<void> clear() async {
    if (state.isLoading) return;
    clearCallCount++;
    state = const AsyncValue.loading();
    if (shouldFail) {
      state = AsyncValue.error(
        const UnexpectedFailure('boom'),
        StackTrace.current,
      );
    } else {
      state = const AsyncValue.data(true);
    }
  }
}

/// Counts how many times it has been *constructed* — a sibling of
/// [SettingsPage] inside the same [AppRestartScope], so a rising count
/// proves `AppRestartScope.restart` actually tore down and rebuilt the
/// subtree in reaction to a successful clear.
class _RestartSentinel extends StatefulWidget {
  const _RestartSentinel({required this.onBuild});

  final ValueChanged<int> onBuild;

  @override
  State<_RestartSentinel> createState() => _RestartSentinelState();
}

class _RestartSentinelState extends State<_RestartSentinel> {
  static int _liveCount = 0;
  late final int _id;

  @override
  void initState() {
    super.initState();
    _id = _liveCount++;
  }

  @override
  Widget build(BuildContext context) {
    widget.onBuild(_id);
    return const SizedBox.shrink();
  }
}

Widget _harness(
  List<Override> overrides, {
  bool wrapInRestartScope = false,
  ValueChanged<int>? onSentinelBuild,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SettingsPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('onboarding-placeholder'))),
      ),
    ],
  );

  final content = ProviderScope(
    overrides: overrides,
    child: Column(
      children: [
        Expanded(child: MaterialApp.router(routerConfig: router)),
        if (onSentinelBuild != null) _RestartSentinel(onBuild: onSentinelBuild),
      ],
    ),
  );

  return wrapInRestartScope ? AppRestartScope(child: content) : content;
}

void main() {
  testWidgets('renders every expected section and the current app version', (
    tester,
  ) async {
    await tester.pumpWidget(_harness([]));
    await tester.pumpAndSettle();

    expect(find.text('Restart Onboarding'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text(AppInfo.displayVersion), findsOneWidget);
    expect(find.textContaining('stored only on this device'), findsOneWidget);
    expect(find.text('Licenses'), findsOneWidget);
    expect(find.text('Clear all local data'), findsOneWidget);
  });

  testWidgets('Restart Onboarding navigates to the onboarding route', (
    tester,
  ) async {
    await tester.pumpWidget(_harness([]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restart Onboarding'));
    await tester.pumpAndSettle();

    expect(find.text('onboarding-placeholder'), findsOneWidget);
  });

  testWidgets(
    'tapping Clear all local data shows a strong, irreversible-warning '
    'confirmation, and Cancel never triggers a clear',
    (tester) async {
      final controller = _FakeClearDataController();

      await tester.pumpWidget(
        _harness([clearDataControllerProvider.overrideWith(() => controller)]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear all local data'));
      await tester.pumpAndSettle();

      expect(find.text('Clear all local data?'), findsWidgets);
      expect(find.textContaining('cannot be undone'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(controller.clearCallCount, 0);
    },
  );

  testWidgets(
    'confirming clear calls the controller and, on success, triggers an '
    'app restart',
    (tester) async {
      final controller = _FakeClearDataController();
      final sentinelIds = <int>[];

      await tester.pumpWidget(
        _harness(
          [clearDataControllerProvider.overrideWith(() => controller)],
          wrapInRestartScope: true,
          onSentinelBuild: sentinelIds.add,
        ),
      );
      await tester.pumpAndSettle();
      expect(sentinelIds.last, 0);

      await tester.tap(find.text('Clear all local data'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
      await tester.pumpAndSettle();

      expect(controller.clearCallCount, 1);
      expect(sentinelIds.last, 1); // subtree was torn down and rebuilt
    },
  );

  testWidgets(
    'a failed clear keeps the user on Settings and shows a readable error',
    (tester) async {
      final controller = _FakeClearDataController()..shouldFail = true;

      await tester.pumpWidget(
        _harness([clearDataControllerProvider.overrideWith(() => controller)]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear all local data'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget); // still here
      expect(find.text('boom'), findsOneWidget);
    },
  );
}
