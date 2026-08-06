import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';

/// Pure presentational button — the caller owns what happens on press and
/// whether a completion is currently in flight. No provider reads here.
class CompleteQuestButton extends StatelessWidget {
  const CompleteQuestButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52, // comfortably above the ~44dp minimum touch target
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(AppLocalizations.of(context)!.completeQuestButton),
      ),
    );
  }
}
