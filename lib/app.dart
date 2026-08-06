import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class PrimeApp extends ConsumerWidget {
  const PrimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // `null` for System mode lets MaterialApp.router's own locale-resolution
    // algorithm pick from the device's locales against `supportedLocales`
    // (English listed first, so it's the fallback for anything unsupported)
    // — see AppLocaleOptionLocale.resolvedLocale's own doc for why.
    final locale = ref.watch(localeControllerProvider).resolvedLocale;

    return MaterialApp.router(
      title: 'Prime',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Dark-first for Phase 0 — theme switching is not implemented yet.
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
