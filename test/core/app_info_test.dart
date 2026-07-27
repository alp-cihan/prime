import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/app_info.dart';

/// Phase 14: "app metadata/version exposure" — a thin guard against the
/// version constant silently drifting into an obviously-wrong shape. It
/// cannot verify agreement with `pubspec.yaml`'s `version:` field at
/// runtime (Dart has no built-in access to that without an extra package —
/// see `AppInfo`'s own doc) — keeping the two in sync by hand at each
/// version bump is documented in docs/release.md instead.
void main() {
  test('version follows semantic versioning (optionally with a pre-release '
      'tag)', () {
    expect(AppInfo.version, matches(RegExp(r'^\d+\.\d+\.\d+(-[\w.]+)?$')));
  });

  test('buildNumber is a positive integer', () {
    expect(AppInfo.buildNumber, greaterThan(0));
  });

  test('displayVersion combines version and buildNumber', () {
    expect(AppInfo.displayVersion, '${AppInfo.version}+${AppInfo.buildNumber}');
  });
}
