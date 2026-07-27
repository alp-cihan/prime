import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/app_restart_scope.dart';

/// Increments once per *construction* (not per rebuild) — proves whether
/// [AppRestartScope.restart] truly tears down and recreates the subtree
/// (a fresh instance, counter back to its initial value) versus merely
/// triggering an ordinary rebuild of the same, still-alive instance (counter
/// would keep climbing).
class _CountingWidget extends StatefulWidget {
  const _CountingWidget({required this.onBuild});

  final ValueChanged<int> onBuild;

  @override
  State<_CountingWidget> createState() => _CountingWidgetState();
}

class _CountingWidgetState extends State<_CountingWidget> {
  static int _liveInstanceCount = 0;
  late final int _instanceId;

  @override
  void initState() {
    super.initState();
    _instanceId = _liveInstanceCount++;
  }

  @override
  Widget build(BuildContext context) {
    widget.onBuild(_instanceId);
    return const SizedBox.shrink();
  }
}

void main() {
  testWidgets(
    'restart() disposes and recreates the whole subtree, not just a rebuild',
    (tester) async {
      final instanceIds = <int>[];

      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: AppRestartScope(
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return _CountingWidget(onBuild: instanceIds.add);
              },
            ),
          ),
        ),
      );

      expect(instanceIds.last, 0); // first construction

      // An ordinary rebuild (setState-free) of the same tree must not
      // recreate the widget — `build()` may run again, but on the *same*
      // still-alive instance.
      await tester.pumpWidget(
        MaterialApp(
          home: AppRestartScope(
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return _CountingWidget(onBuild: instanceIds.add);
              },
            ),
          ),
        ),
      );
      expect(instanceIds.last, 0); // still the same instance

      AppRestartScope.restart(capturedContext);
      await tester.pumpAndSettle();

      expect(instanceIds.last, 1); // a brand-new instance was constructed
    },
  );
}
