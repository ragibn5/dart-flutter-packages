# app_template

A template to start new applications from.

## Getting Started

### Setup environment

#### Install required plugins

1. Make sure you have the following plugins installed:
    - [Dart](https://plugins.jetbrains.com/plugin/6351-dart)
    - [Flutter](https://plugins.jetbrains.com/plugin/9212-flutter)
    - [Flutter Intl](https://plugins.jetbrains.com/plugin/13666-flutter-intl)
2. Other recommended plugins for better productivity:
    - [Bloc](https://plugins.jetbrains.com/plugin/12129-bloc)
    - [Dart Data Class](https://plugins.jetbrains.com/plugin/12429-dart-data-class)
    - [String Manipulation](https://plugins.jetbrains.com/plugin/2162-string-manipulation)
    - [Regexp Tester](https://plugins.jetbrains.com/plugin/2917-regexp-tester)
    - [Translation](https://plugins.jetbrains.com/plugin/8579-translation)
3. Restart Android Studio afterward for the plugins to work properly.

#### Setup Flutter & Dart runtime

(Make sure you have the project opened in Android studio.)

1. Make sure you have [FVM](https://fvm.app/documentation/getting-started) installed.
   It is recommended to use the latest Flutter & Dart SDK version as the global runtime. Run the
   following command to set up the global Flutter & Dark runtime (Considering 3.29.2 is the latest).
   ```bash
   fvm global 3.29.2
   ```
   Please note, if you are NOT using FVM in existing projects, and using a different runtime version
   globally, changing global runtime may break those projects. But you can use fvm to use a
   particular runtime version for each project.
2. Open the Android studio terminal window for the project, and run the following command from the
   project root to set up supported Flutter & Dart sdk version for the project. The project was
   created using flutter version 3.29.2 and you must use at least that or above.
   (Considering 3.29.2 is the latest)
   ```bash
   fvm use 3.29.2
   ```
   You should have the latest Flutter & Dart SDK installed globally. See the previous section for
   more details on how to set up global runtime.

#### Setup localization for the project

(Make sure you have the project opened in Android studio.)

1. Open the Android studio terminal window for the project, and run the following command from the
   project root to activate latest intl_utils.
   ```bash
   fvm flutter pub global activate intl_utils
   ```
2. Goto `Tools` >> `Flutter Intl` >> `Initialize for the project`.
   This may already be initialized, but doing this makes sure it is reinitialized properly on your
   machine.

### Set up flavors

You should automatically get the following run configurations set up for you, for all the supported
platforms:

- dev
- exp
- stage
- prod

### Set up app/project specific identifiers, resources & services

▶️ **If you want to complete this step with an automated script, run
the [setup.sh](setup.sh).**

Or, follow the steps bellow.

You may want to modify the platform specific values and components to get started:

- **Dart package name:<br>**
  Change the dart package name inside `pubspec.yaml`. Make sure to
- **App Id:<br>**
  Before changing the app id, as a precaution, please note that the app id should not contain
  underscores or hyphens, and should be composed solely of lowercase characters and dots. As an
  warning, iOS does not support '_' in it's app id, and Android does not support '-' in it's app id.
  So, you can already see where this goes.

  Here is how to change the app id for each platform.
    - Android:<br>
      Open `android/app/build.gradle.kts` and replace the the `applicationId` key's value with your
      desired app id. Please note, the template maintains different application id by adding suffix
      after the main application id you just changed. If it is required to have totally different
      application id for each flavor (that is not achievable by adding suffixes), you can override
      `applicationId` directly for specific product flavor as following (here, for dev, as an
      example):
      ```kotlin
      productFlavors {
        create("dev") {
            // Other properties remain same ...
            applicationId = "com.ragibn5.fat.dev"
        }
        
        // Same for other flavors ...
      }
      ```
      **Please note**, it is not required to restructure the source code directory, but it is
      recommended. For example, after cloning, the kotlin or java code may be in
      `com/ragibn5/vfat`. And later, if you change the base app id to `com.ragib.fltemplate`, as a
      convention, you may want to move the source files to `com/ragib/fltemplate`. In that case,
      please make sure to keep a backup before proceeding. You should also change the `nameSpace` to
      `com.ragib.fltemplate` (or same as the directory path, replaced by period (.)) if you have
      restructured the source directory.
      **<br>Also,** you should not create random app id for each flavor, nor restructure the source
      directory as per a specific flavor's app id, rather, maintain a base app id under
      `defaultConfig` and create flavor specific app ids from that (using `applicationIdSuffix`),
      and restructure the source directory according to that base app id as well.
    - iOS:<br>
        1. Open the ios project on XCode and go to the `Runner` target as before.
        2. Under `Signing & Capabilities`, select the desired configuration from the menu next to
           `+ Capability`and modify the `Bundle Identifier` to your desired one. While doing so, you
           should also set up your team and signing management.
- **App name:**
  (Currently, it is not possible to have flavor wise localized app names in iOS.)
    - Android:<br>
      Open `android/app/src/<flavor_name>/res/values/strings.xml` and change the `app_name` key's
      value to your desired one. `<flavor_name>` is either `dev`,`exp`,`stage`, or `prod`. If you
      want to change the name for a specific language, open that string file (for example
      `strings-bn.xml`) and do the same.
    - iOS:<br>
        1. Open the iOS Flutter project in Xcode.
        2. Click `Runner` from the project navigator (usually the first item in the list)
        3. Select the `Runner` from Target section (usually located at the right of the project
           navigator)
        4. Select the `Build Settings` tab and search for `APP_DISPLAY_NAME`.
        5. Expand the `APP_DISPLAY_NAME` option, and set your desired names for each flavor.
- **Launcher icon:<br>**
  Find flavor specific launcher image generator config files. These are located at the root of the
  flutter project and usually named `flutter_launcher_icons-<flavor-name>.yaml`. For example, for
  `dev` flavor, it is `flutter_launcher_icons-dev.yaml`. Modify the properties for each flavor (at
  each corresponding config file), and run the following command for the changes to take effect. If
  you want to a use single appearance for all flavors, use the same value for all the configuration
  fields.
  ```bash
  fvm dart run flutter_launcher_icons
  ```
- **Splash/Launcher Screen:<br>**
  Find flavor specific splash image generator config files. These are located at the root of the
  flutter project and usually named `flutter_native_splash-<flavor_name>.yaml`. For example, for
  `dev` flavor, it is `flutter_native_splash-dev.yaml`. Modify the properties for each flavor (at
  each corresponding config file), and run the following command for the changes to take effect. If
  you want to a use single appearance for all flavors, use the same value for all the configuration
  fields.
  ```bash
  fvm dart run flutter_native_splash:create --all-flavors
  ```
  Please note, the package used to generate the launcher icons contains bugs, which causes it to
  corrupt the file at `ios/Runner.xcodeproj/project.pbxproj`. After running the command, open this
  file and do the following to fix the errors:
    - It may generate gibberish (and this is actually what corrupts the file) at the end of the
      file, just discard the changes there.
    - Replace any occurrence of
      `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon-<flavor-name>;` with
      `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;`. Here, `<flavor-name>`
      is one of `dev`, `exp`, `stage`, or `prod`.
    - Go to the `Build Settings` tab again (follow the same steps as changing the app name to open
      it), and search for `Primary App Icon Set Name`. Make sure it is same
      as [this](assets/external/guides/ios_launcher_icon_flavored_values.jpeg).
- **Firebase:<br>**
    - Assuming you have the latest Flutter Dart SDK set up globally (if not, follow instructions
      from previous sections).
    - Install and activate the firebase tools globally (or skip if already activated)
      from [here](https://firebase.google.com/docs/flutter/setup?platform=android). Only perform the
      actions in step 1 and 2. Remaining ones are automated for you. See the next steps.
    - Assuming you already created firebase projects for each flavor. For simplicity, we are using
      the same firebase project, but it is recommended to use different firebase project per flavor.
    - Please find and open the [`firebase_setup.sh`](firebase_setup.sh). Change the
      `default_project`, `default_ios_bundle` and `default_android_pkg` for each flavor. If the apps
      do not yet exist in firebase, they will be created.
    - Finally, run this script file (from the run icon on top of the file). This will overwrite the
      existing related files with your firebase files.

### Final TODOs

🎯 Congratulations! You’ve successfully set up the project.

🔄 Next step: Restart your IDE — it's recommended to clean the IDE cache beforehand.

🛠️ Update the following to reflect your project:

- 📄 README.md
- 📄 pubspec.yaml (update these fields):
    - name
    - description
    - repository
    - issue_tracker
    - homepage
    - And anything other that reflects any template project property.

<br>

⚠️ No matter what you do, XCode will have some issues:

- Make sure we have GoogleService-Info.plist inside ios/Runner dir.
- If not, copy ios/Config/Firebase/dev/GoogleService-Info.plist and paste it to ios/Runner folder.
- If there are any issue related to pod and Podfile, delete Podfile.lock and then run pod install or
  pod repo update.

<br>

🎯 Verify the project setup by running it into all platforms.