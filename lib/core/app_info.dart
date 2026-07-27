/// Single source of truth for app version metadata *outside* pubspec.yaml.
///
/// Flutter has no built-in way to read `pubspec.yaml`'s `version:` field at
/// runtime without an extra package (e.g. `package_info_plus`) — this app
/// avoids that dependency for one small, static value. **Must be kept in
/// sync with `pubspec.yaml`'s `version:` field by hand** — see
/// docs/release.md's "Version bump process" for the exact steps this
/// implies.
abstract final class AppInfo {
  static const String version = '1.0.0-beta.1';
  static const int buildNumber = 1;
  static const String displayVersion = '$version+$buildNumber';
}
