import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap/hive_bootstrap.dart';
import 'core/app_restart_scope.dart';
import 'l10n/app_localizations.dart';

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
  // AppRestartScope wraps ProviderScope (not the other way around) so that
  // "clear all local data" (Settings) can throw away and rebuild the entire
  // provider container — see AppRestartScope's own doc for why.
  runApp(const AppRestartScope(child: ProviderScope(child: PrimeApp())));
}

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      // Hive hasn't opened yet at this point (that's why this screen is
      // showing), so the user's saved language preference is unreachable —
      // this falls back to the device locale via the same
      // `supportedLocales`-driven resolution `app.dart` uses in System mode.
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 16),
                      Text(
                        l10n.startupFailureTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.startupFailureBody,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
