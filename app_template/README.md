# app_template

A template to start new applications from.

## Setup environment

### Install required plugins

1. Required plugins:
    - [Dart](https://plugins.jetbrains.com/plugin/6351-dart)
    - [Flutter](https://plugins.jetbrains.com/plugin/9212-flutter)
    - [Flutter Intl](https://plugins.jetbrains.com/plugin/13666-flutter-intl)
    - [Bloc](https://plugins.jetbrains.com/plugin/12129-bloc)
2. Recommended for better productivity:
    - [Dart Data Class](https://plugins.jetbrains.com/plugin/12429-dart-data-class)
    - [String Manipulation](https://plugins.jetbrains.com/plugin/2162-string-manipulation)
    - [Regexp Tester](https://plugins.jetbrains.com/plugin/2917-regexp-tester)
    - [Translation](https://plugins.jetbrains.com/plugin/8579-translation)
3. Restart Android Studio afterward for the plugins to work properly.

### Set up Flutter & Dart runtime

1. Install [FVM](https://fvm.app/documentation/getting-started) if not already installed.
2. From the project root, install and pin the supported SDK version (see [`.fvmrc`](.fvmrc)):
   ```bash
   fvm use 3.41.9
   ```

### Setup localization

1. The project relies on `Flutter Intl` to manage localization in this project. In Android Studio, go to `Tools` >> `Flutter Intl` >> `Initialize for the project`. This may already be initialized, but running it ensures a proper setup on your machine.
2. The Flutter Intl plugin requires global activation of `intl_utils`. If not already activated, you may need to run the following command to activate the `intl_utils` globally.
   ```bash
   fvm flutter pub global activate intl_utils
   ```

## Running the app

Four build flavors are supported:

- `dev`: For you, the developer, to do daily development work.
- `exp`: For testers or QA people.
- `stage`: For testing release candidates in production mirrors.
- `prod`: For end users – final destination.

```bash
# Development
fvm flutter run --flavor dev -t lib/main_dev.dart
```

```bash
# Experimental
fvm flutter run --flavor exp -t lib/main_exp.dart
```

```bash
# Staging
fvm flutter run --flavor stage -t lib/main_stage.dart
```

```bash
# Production
fvm flutter run --flavor prod -t lib/main_prod.dart
```

Or, from Android Studio, use the pre-configured run configurations.

## Code generation

The project uses code generation to generate many of its components. Run the following commands to regenerate all generated code, especially when setting up for the first time.

```bash
# Generate dart codes
fvm dart run build_runner build --delete-conflicting-outputs

# Generate assets
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Generate localizations
fvm dart run intl_utils:generate
# Or, by global intl installation
# fvm flutter pub global run intl_utils:generate


```

These files should not be edited manually.

## Testing & coverage

Run all tests:

```bash
fvm flutter test
```

Or, with coverage:

```bash
fvm flutter test --coverage
```

Even better, you can run the tests, generate, and view the coverage report via pre-configured Makefile commands:

```bash
make view-coverage
```

## Conventions

See [CONVENTIONS.md](CONVENTIONS.md) for the project conventions and development guidelines.

## Whitelabel

See [WHITELABEL.md](WHITELABEL.md) for instructions on customizing this template for your own app. Covers flavors, package name, app id, app name, launcher icon, splash screen, and Firebase setup.

## License

Click [here](../LICENSE) to see the license.