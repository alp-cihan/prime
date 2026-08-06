import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prime/l10n/app_localizations.dart';

/// Standard localization wiring for widget tests that build their own
/// `MaterialApp`/`MaterialApp.router` (rather than `PrimeApp`, which already
/// wires this in `app.dart`) — every screen now resolves strings through
/// `AppLocalizations.of(context)!`, so any test harness rendering one needs
/// these present or that call throws a null-check error.
const testLocalizationsDelegates = <LocalizationsDelegate<Object?>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const testSupportedLocales = AppLocalizations.supportedLocales;
