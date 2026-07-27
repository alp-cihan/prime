import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap/hive_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await bootstrapHive();
  } catch (error, stackTrace) {
    // Local storage failing to open (e.g. a corrupted box file) must not
    // surface as an unhandled crash/blank screen — there is nothing else
    // useful to do at this point (every provider reads through the boxes
    // this opens), so show one clear, actionable screen instead.
    debugPrint('Prime failed to start: $error\n$stackTrace');
    runApp(_StartupFailureApp(error: error));
    return;
  }
  runApp(const ProviderScope(child: PrimeApp()));
}

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 16),
                  const Text(
                    "Prime couldn't start",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your data could not be loaded. Restarting the app '
                    'usually fixes this.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
