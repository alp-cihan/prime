# Prime — Beta Release Guide

This covers building, signing, versioning, and installing Prime for Android
beta testing. Prime is offline-first with no backend, so there is no server
deployment step — this document is entirely about the Android app artifact.

## Development build

Run against a connected device or emulator, with hot reload:

```
flutter run
```

To test the web build specifically (used during development for quick
iteration, not a beta distribution target):

```
flutter run -d web-server
```

## Release builds

### Debug APK

Fastest way to get an installable artifact on a physical device for manual
testing — not optimized, not for distribution:

```
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Without a `key.properties` file (see "Signing setup" below), this is signed
with the debug keystore automatically — it installs and runs identically to
a real release build, but **is not acceptable for any store submission**
(Android/Play Store require a real, consistent release signature across
updates). It is fine for direct-install beta testing (sideloading).

### Android App Bundle (for Play Console upload, if ever needed)

```
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## Signing setup

Prime's `android/app/build.gradle.kts` already contains the standard
Flutter release-signing wiring: if `android/key.properties` exists, its
values configure a real `release` signing config; if it doesn't, the release
build type falls back to the debug keystore (the out-of-the-box state,
committed to this repo).

**`key.properties` and any keystore file are git-ignored — never commit
them.** `android/key.properties.example` documents the expected format.

To set up real signing:

1. Generate a keystore (do this once, store it somewhere safe and backed up
   — losing it means you can never publish an update under the same app
   identity again):
   ```
   keytool -genkey -v -keystore ~/prime-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias prime
   ```
2. Copy `android/key.properties.example` to `android/key.properties` and
   fill in the real `storePassword`, `keyPassword`, `keyAlias`, and
   `storeFile` (path to the `.jks` from step 1).
3. Run `flutter build apk --release` (or `appbundle`) again — it now signs
   with the real key automatically.

## Version bump process

Prime's version has **two places that must be updated together by hand**
(there is no single source of truth read at build time from one file):

1. `pubspec.yaml`'s `version:` field — format `MAJOR.MINOR.PATCH[-prerelease]+BUILD`.
   `BUILD` becomes Android's `versionCode` (must strictly increase for every
   Play Store upload); the part before `+` becomes `versionName`.
2. `lib/core/app_info.dart`'s `AppInfo.version`/`AppInfo.buildNumber` —
   shown in Settings. Must match `pubspec.yaml` exactly (see that file's own
   doc comment for why this isn't automated: reading `pubspec.yaml` at
   runtime needs an extra package, which this project deliberately avoids
   for one small value).

There is a unit test (`test/core/app_info_test.dart`) that guards
`AppInfo`'s own internal shape, but nothing currently *cross-checks*
`AppInfo` against `pubspec.yaml` automatically — treat that as a manual step
of the bump, not an automated one.

## Installing on a physical Android device

With the device connected via USB (developer mode + USB debugging enabled):

```
flutter install
```

or, for an already-built APK:

```
adb install build/app/outputs/flutter-apk/app-release.apk
```

Without a cable, copy the APK to the device (email, cloud drive, etc.) and
open it there — Android will prompt to allow installing from that source if
it isn't already permitted.

## Android configuration reference

| Setting | Value | Notes |
|---|---|---|
| Application ID | `com.alpci.prime` | A real, working id — not a placeholder — but built on a personal namespace; reassign to an owned domain before any store submission. |
| minSdk / targetSdk | Flutter tool defaults (`flutter.minSdkVersion` / `flutter.targetSdkVersion`) | Not pinned to a specific number in `build.gradle.kts` — they track whatever this Flutter SDK version ships as its floor/ceiling, so they move forward automatically on `flutter upgrade`. |
| Permissions | None declared | Prime is fully offline; no network/storage/camera permission is requested, and none should be added without a real feature that needs it. |
| Backup | `android:allowBackup="true"` (explicit) | Deliberate: local data has no secrets, so Android Auto Backup restoring it on reinstall is a benefit. |
| Orientation | Portrait-locked (`android:screenOrientation="portrait"`) | No screen in this app was designed for landscape. |
| R8 / ProGuard | Off (left at the implicit default) | Deliberate for this beta — see the comment in `build.gradle.kts` for what to verify before turning it on, and why that file deliberately does *not* spell out `isMinifyEnabled = false` (writing it explicitly conflicts with the Flutter Gradle plugin's own `shrinkResources` default and fails the build). |
| Signing | Debug-signed until `key.properties` exists | See "Signing setup" above. |

## Required assets before wider distribution

Not produced in this phase (Phase 14 explicitly excludes final store
artwork) — placeholders are wired up correctly and documented here so
replacing them later is a drop-in asset swap, not a re-plumbing job:

- **Launcher icon**: still Flutter's default template icon
  (`android/app/src/main/res/mipmap-*dpi/ic_launcher.png`) plus an adaptive
  icon (`mipmap-anydpi-v26/ic_launcher.xml`) that reuses the same legacy PNG
  as its foreground against a solid dark background
  (`@color/ic_launcher_background`, `#0A0A0B` — Prime's actual dark surface
  color). Needs: a real foreground mark sized for the standard ~66% adaptive
  safe zone, at minimum 512×512, plus regenerated legacy PNGs per density
  bucket (Android Studio's Image Asset tool, or `flutter_launcher_icons`,
  handle this in one step from a single source image).
- **Play Store feature graphic / screenshots**: none exist; out of scope for
  this phase (non-goal: "final marketing screenshots").
- **App description copy for a store listing**: `pubspec.yaml`'s
  `description:` field and `web/manifest.json`'s `description` are both
  real, current copy — reusable as a starting point for a store listing,
  not written as one.

## Known release blockers (do not claim Play Store readiness)

- Release APK/AAB is debug-signed until a real keystore is set up (see
  "Signing setup").
- Launcher icon is still the Flutter default template, not Prime branding.
- No Play Store listing assets (screenshots, feature graphic, privacy
  policy URL) exist.
- `applicationId` sits under a personal namespace rather than an owned
  organization domain.
- R8/ProGuard has never been exercised against a release build — if
  enabled later, every feature needs manual verification against that build
  specifically before shipping.
- Story and Journal tabs are intentional placeholders this phase, not
  incomplete features hidden by accident — see their own in-code doc
  comments.
