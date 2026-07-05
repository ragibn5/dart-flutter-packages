# Whitelabel

This document describes how to customize this template for your own app.

## Set up flavors

Run configurations for all platforms are pre-configured for these flavors:

- dev
- exp
- stage
- prod

See [Running the app][running-app] in the main README.

## Set up app identifiers, resources, and services

▶️ **To run the automated setup script:** `bash scripts/whitelabel.sh`

Or, follow the manual steps below.

### Dart package name

Change the `name` field in `pubspec.yaml`.

### App ID

App IDs must use only lowercase letters and dots (no underscores or hyphens). iOS forbids `_`; Android forbids `-`.

- **Android:** Open `android/app/build.gradle.kts` and update `applicationId` under `defaultConfig`. The template appends a suffix per flavor (`.dev`, `.exp`, `.stage`, none for prod). If you need completely different IDs per flavor, override `applicationId` directly inside each flavor block:

  ```kotlin
  productFlavors {
    create("dev") {
        applicationId = "com.example.app.dev"
    }
  }
  ```

  Restructuring the Kotlin source directory to match the new package is optional but recommended. If you do, update the `namespace` field in the same file to match. Keep the base app ID in `defaultConfig` and only vary via `applicationIdSuffix` — do not restructure per flavor.

- **iOS:** Open the project in Xcode, select `Runner` > `Signing & Capabilities`, choose the configuration from the menu next to `+ Capability`, and update `Bundle Identifier`. Also set up your team and signing.

### App name

*(Flavor-wise localized app names are not supported on iOS.)*

- **Android:** Edit `android/app/src/<flavor>/res/values/strings.xml` — change `app_name`. For other languages, edit the corresponding `strings-<locale>.xml`.
- **iOS:** In Xcode, select `Runner` > `Build Settings`, search for `APP_DISPLAY_NAME`, expand it, and set names per flavor.

### Launcher icon

Edit the flavor-specific config files (`flutter_launcher_icons-<flavor>.yaml`) at the project root, then run:

```bash
fvm dart run flutter_launcher_icons
```

### Splash screen

Edit the flavor-specific config files (`flutter_native_splash-<flavor>.yaml`), then run:

```bash
fvm dart run flutter_native_splash:create --all-flavors
```

> **Known bug in `flutter_launcher_icons`:** The package may corrupt `ios/Runner.xcodeproj/project.pbxproj`. After running the command, open that file and:
> - Discard any gibberish appended at the end.
> - Replace `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon-<flavor>;` with `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;`.
> - In Xcode `Build Settings`, verify `Primary App Icon Set Name` matches [this reference][icon-guide].

### Firebase

1. Ensure `flutterfire` CLI is installed ([guide][firebase-setup] — steps 1–2 only).
2. Create Firebase projects (one per flavor recommended, but a single project works too).
3. Open [`scripts/firebase_setup.sh`][firebase-script] and update `default_project`, `default_ios_bundle`, and `default_android_pkg` for each flavor.
4. Run the script — it creates missing Firebase apps and overwrites the config files.

## Final TODOs

🎯 **You're all set!**

- 🔄 Restart your IDE (clear cache recommended).
- 🛠️ Update `README.md` and `pubspec.yaml` fields (`name`, `description`, `repository`, `issue_tracker`, `homepage`, etc.).
- ⚠️ **Xcode** — ensure `GoogleService-Info.plist` is in `ios/Runner/`. If missing, copy from `ios/Config/Firebase/dev/`. For pod issues, delete `Podfile.lock` and run `pod install` or `pod repo update`.
- 🎯 Verify the project builds and runs on all target platforms.

---

[running-app]: README.md#running-the-app

[icon-guide]: assets/external/guides/ios_launcher_icon_flavored_values.jpeg

[firebase-script]: scripts/firebase_setup.sh

[firebase-setup]: https://firebase.google.com/docs/flutter/setup?platform=android
