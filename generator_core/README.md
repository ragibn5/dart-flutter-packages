# generator_core

Core components to build a custom Dart generator package.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  generator_core: ^1.0.1
```

#### Or, From Git repo

```yaml
dependencies:
  generator_core:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: generator_core
      ref: generator_core-1.0.1
```

---

## 💡 Why This Package Exists

`generator_core` is a small foundational package for writing custom Dart code generators. It sits on top of the official builder/generator APIs and adds the reusable structure most real code-gen libraries need.

The official APIs give you the raw building blocks — builders, generators, resolvers, and much more. This package focuses on the missing application-level layer around those APIs.

It provides:

- **Shared generator config** — load generator-specific config once and reuse it across build steps.
- **Typed session context** — pass typed config and debugging setup into your builders and generators without manual wiring.
- **User-friendly debugging** — write structured file logs from generators running inside builder/generator runner.

## 🚀 Quick start

The core idea is straightforward.

- write your own config model
- write a config loader that loads the config
- write a builder/generator that uses the config

And, the package handles the repeated infrastructure around them. Here is how you build a minimal generator in 4 steps:

### 1. Build the builder

The build runner looks for a top-level function that returns a `Builder`. Use `GeneratorBuilder` to create one.

```dart
import 'package:generator_core/generator_core.dart';

Builder exampleBuilder(BuilderOptions options) {
  return GeneratorBuilder<ExampleConfig, ExampleBuilder>(
    configLoader: ExampleConfigLoader(options),
    factory: (sessionDataManager) => ExampleBuilder(sessionDataManager: sessionDataManager),
  ).build();
}
```

| Parameter      | Description                                                                             |
|----------------|-----------------------------------------------------------------------------------------|
| `configLoader` | A `ContextConfigLoader` subclass class that loads your config from any source you want. |
| `factory`      | Receives the shared `SessionDataManager` and returns your builder instance.             |

<br>You also need a `build.yaml` at the package root to register the builder:

```yaml
builders:
  example_builder:
    import: "package:my_package/builder.dart"
    builder_factories: [ "exampleBuilder" ]
    build_extensions: { r"$lib$": [ "generated/example/output.dart" ] }
    auto_apply: dependents
    build_to: source
```

| Field               | What it means in plain English                                                                                                                                                                                                                 |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `example_builder`   | A unique name for your builder. Used in logs and when other packages refer to it. From the setup above, it is `example_builder`.                                                                                                               |
| `import`            | The package-style path to your builder file. From the setup above, it is `package:my_package/builder.dart` (the file is at `lib/builder.dart`).                                                                                                |
| `builder_factories` | The name of the entry-point function. From the setup above, it is `exampleBuilder`.                                                                                                                                                            |
| `build_extensions`  | Maps inputs to outputs. From the setup above, it is `{ r"\$lib\$": ["generated/example/output.dart"] }` — "when any file under `lib/` is processed, generate this output". Available placeholders are `$lib$`, `$test$`, `$web$`, `$package$`. |
| `auto_apply`        | Controls *which packages* the builder runs on. From the setup above, it is `dependents` — run on every package that depends on yours. Other options: `none`, `all_packages`, `root_package`.                                                   |
| `build_to`          | Where to write the output. From the setup above, it is `source` — right into the package's `lib/` folder (visible to users). Alternative: `cache` (hidden build cache).                                                                        |

This is a fairly minimal `build.yaml`. The full schema supports many more options like targets, per-builder options, and builder chaining. See the packages within the [Resources](#resources) section for more details.

### 2. Define generator config

Extend `ContextConfig` to bundle your generator's settings with other the built-in fields.

```dart
class ExampleConfig extends ContextConfig {
  final String outputPathRelativeToLib;

  const ExampleConfig({
    required super.logConfig,
    this.outputPathRelativeToLib = 'generated/example/output.dart',
  });

  @override
  Map<String, dynamic> toMap() => {
    'logConfig': logConfig.toMap(),
    'outputPathRelativeToLib': outputPathRelativeToLib,
  };
}
```

### 3. Load config per package

Extend `ContextConfigLoader` and implement `loadPluginConfig`. Read generator-specific values from `BuilderOptions` (the `build.yaml` config).

It is up to you where you want to load the config from. For example, from the passed [BuilderOptions] (recommended for a generator/builder package), a YAML file, or any other source.

```dart
class ExampleConfigLoader extends ContextConfigLoader<ExampleConfig> {
  ExampleConfigLoader(super.builderOptions);

  @override
  ExampleConfig loadPluginConfig(BuildStep buildStep, BuilderOptions builderOptions) {
    final options = builderOptions.config;

    return ExampleConfig(
      logConfig: const LogConfig(
        logDirectoryRelativePathFromCurrentDir: 'build/logs',
      ),
      outputPathRelativeToLib:
          options['output_path_relative_to_lib'] as String? ??
          'generated/example/output.dart',
    );
  }
}
```

### 4. Write a builder

Extend `SessionManagedRawBuilder<T>` (for raw `Builder` output) or `SessionManagedGenerator<T>` (for `source_gen`-based `Generator` output). By the time `buildWithSession` runs, config is loaded and the type is verified.

```dart
class ExampleBuilder extends SessionManagedRawBuilder<ExampleConfig> {
  ExampleBuilder({required super.sessionDataManager});

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['generated/example/output.dart'],
  };

  @override
  Future<void> buildWithSession(
    BuildStep buildStep,
    BuildSessionContext<ExampleConfig> sessionContext,
  ) async {
    sessionContext.logger.logInfo(
      tag: 'ExampleBuilder',
      message: 'Generating for ${buildStep.inputId.path}',
      extras: sessionContext.config.toMap(),
    );

    final outputId = AssetId(
      buildStep.inputId.package,
      'lib/${sessionContext.config.outputPathRelativeToLib}',
    );
    await buildStep.writeAsString(outputId, '// generated output');
  }
}
```

## API

Everything is exported from a single import:

```dart
import 'package:generator_core/generator_core.dart';
```

| Component                                    | Purpose                                                                                   |
|----------------------------------------------|-------------------------------------------------------------------------------------------|
| `GeneratorBuilder<C, B>`                     | Type-safe builder — wires config loader and factory to a shared `SessionDataManager`.     |
| `SessionManagedRawBuilder<T>`                | Base class for raw `Builder` subclasses with typed config and debugging setup.            |
| `SessionManagedGenerator<T>`                 | Base class for `Generator` subclasses with typed config and debugging setup.              |
| `SessionManagedGeneratorForAnnotation<A, C>` | Base class for `GeneratorForAnnotation` subclasses with typed config and debugging setup. |
| `ContextConfig`                              | Base config model — extend with your generator's options.                                 |
| `ContextConfigLoader<C>`                     | Loads config from `BuilderOptions` (or any other source), per `BuildStep`.                |
| `BuildSessionContext<T>`                     | Typed config + logger passed to builder/generator methods.                                |
| `LogConfig`                                  | Enables/disables file logging and log levels.                                             |
| `SessionDataManager`                         | Caches session data per package.                                                          |
| `SessionLogger`                              | Logger with global and per-level switches.                                                |

## Examples

See [json_parser_generator](../json_parser/json_parser_generator) for a real-world generator built with this package.

## Resources

These official packages provide the foundational APIs that `generator_core` builds on top of:

- [build](https://pub.dev/packages/build) — Core build system: `Builder`, `BuildStep`, asset access, resolvers, and the execution model.
- [source_gen](https://pub.dev/packages/source_gen) — Higher-level layer on top of `build` and `analyzer` for annotation-driven generation.
- [build_config](https://pub.dev/packages/build_config) — Defines how builders are configured in `build.yaml`, including targets, options, and build extensions.
- [build_runner](https://pub.dev/packages/build_runner) — The runner used during development to execute builders, rebuild outputs, and manage the asset graph.
- [build_test](https://pub.dev/packages/build_test) — Test utilities for verifying builder behavior and generated outputs.
- [code_builder](https://pub.dev/packages/code_builder) — Structured Dart code generation instead of raw strings.
- [dart_style](https://pub.dev/packages/dart_style) — Formats generated Dart source before writing to disk.
- [analyzer](https://pub.dev/packages/analyzer) — Dart analysis model for inspecting types, classes, and annotations in generators.
- [glob](https://pub.dev/packages/glob) — File matching patterns useful for scanning input assets.
- [path](https://pub.dev/packages/path) — Platform-safe path normalization and joining.
- [yaml](https://pub.dev/packages/yaml) — Reading YAML configuration files.
