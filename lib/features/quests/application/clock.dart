// Phase 10: `Clock`/`SystemClock` moved to `core/domain/clock.dart` once
// achievements became a second consumer (see that file's doc). Re-exported
// here, unchanged, so every existing import of this path across the quests
// feature (and its tests) keeps working without a mass find-replace.
export '../../../core/domain/clock.dart';
