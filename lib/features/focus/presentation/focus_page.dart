import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/app_localizations.dart';

/// Full-screen, outside the 5-tab shell — per docs/architecture.md §2/§19,
/// Focus Mode must never live inside the main navigation chrome.
class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimePageScaffold(title: AppLocalizations.of(context)!.focusTitle);
  }
}
