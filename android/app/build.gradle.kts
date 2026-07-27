import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Real release signing, without ever committing a secret: if a `key.properties`
// file exists next to this one (see `android/key.properties.example` for the
// expected format, and docs/release.md's "Signing setup" section), its values
// wire up a real release signing config below. `key.properties` itself is
// git-ignored (see android/.gitignore) — nothing here can leak a keystore
// path/password even if this file is committed. Absent that file (the
// out-of-the-box state), the release build type falls back to the debug
// signing config, exactly as Flutter's own template does, so
// `flutter build apk --release` keeps working with no setup.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.alpci.prime"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // A real (though personal-domain-based) application id, not a
        // placeholder — see docs/release.md for whether this needs to
        // change before any store submission.
        applicationId = "com.alpci.prime"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // No key.properties yet — sign with the debug keys instead of
                // failing the build, so `flutter build apk --release` and
                // `flutter run --release` work out of the box. This produces
                // an installable-for-testing, but not store-distributable,
                // release build. See docs/release.md.
                signingConfigs.getByName("debug")
            }
            // R8/ProGuard: deliberately NOT enabled for this beta (left at
            // the implicit default of off) — Prime has no reflection-heavy
            // native plugins (Hive CE uses generated adapters, not
            // reflection) so shrinking would likely be safe, but it hasn't
            // been verified against a release build yet, and a beta
            // candidate should not risk a shrinking-related crash for a
            // code-size win. To enable later: set isMinifyEnabled = true,
            // add a proguard-rules.pro and reference it via
            // proguardFiles(...), then manually test every feature against
            // the release build before shipping. (Explicitly writing
            // `isMinifyEnabled = false` here — even though that's the
            // existing default — conflicts with the Flutter Gradle plugin's
            // own `shrinkResources` default for the release build type and
            // fails the build, so the setting is intentionally left
            // unwritten rather than spelled out.)
        }
    }
}

flutter {
    source = "../.."
}
