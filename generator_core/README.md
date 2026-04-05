# generator_core

Core components to build a custom dart generator package.

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dependencies:
  generator_core: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dependencies:
  generator_core:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: generator_core
      ref: main
```

## Getting Started

A typical integration looks like this:

1. Create a config model (specific to your package) by extending `ContextConfig`.
2. Create a config loader by extending a `ContextConfigLoader` and use that to load the config.
3. Create a builder factory (typically in `lib/builder.dart`) and configure entry points.
   The official docs are not so organized. Please have a look at following (preferably in order) for
   more info:
    - [build](https://pub.dev/packages/build)
    - [source_gen](https://pub.dev/packages/source_gen)
    - [build_config](https://pub.dev/packages/build_config)
4. Create a `SessionDataManager` once for that builder or generator.
5. Extend `SessionManagedGenerator` or `SessionManagedRawBuilder` and implement
   your generation logic with access to a typed config and shared session
   logger.

Overall flow:

```dart
import 'package:build/build.dart';
import 'package:generator_core/generator_core.dart';

// Package-specific config model.
class ExampleConfig extends ContextConfig {
  final String outputPathRelativeToLib;

  const ExampleConfig({
    required super.logConfig,
    required this.outputPathRelativeToLib,
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'logConfig': logConfig.toMap(),
        'outputPathRelativeToLib': outputPathRelativeToLib,
      };
}

// Reads package-specific options from build.yaml / BuilderOptions.
class ExampleConfigLoader extends ContextConfigLoader<ExampleConfig> {
  ExampleConfigLoader(super.builderOptions);

  @override
  ExampleConfig loadPluginConfig(BuildStep buildStep,
      BuilderOptions builderOptions,) {
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

// The builder receives a typed session context for each build step.
class ExampleBuilder extends SessionManagedRawBuilder<ExampleConfig> {
  ExampleBuilder({required super.sessionDataManager});

  @override
  Map<String, List<String>> get buildExtensions =>
      {
        // This should match the output path your builder writes to.
        r'$lib$': ['generated/example/output.dart'],
      };

  @override
  Future<void> buildWithSession(BuildStep buildStep,
      BuildSessionContext<ExampleConfig> sessionContext,) async {
    sessionContext.logger.logInfo(
      tag: 'ExampleBuilder',
      message: 'Generating for ${buildStep.inputId.path}',
      extras: sessionContext.config.toMap(),
    );

    // Resolve the final output from the shared config for this package.
    final outputId = AssetId(
      buildStep.inputId.package,
      'lib/${sessionContext.config.outputPathRelativeToLib}',
    );
    await buildStep.writeAsString(outputId, '// generated output');
  }
}

// Typical lib/builder.dart entrypoint.
Builder exampleBuilder(BuilderOptions options) {
  final sessionDataManager = SessionDataManager.createNewInstance(
    ExampleConfigLoader(options),
  );

  return ExampleBuilder(sessionDataManager: sessionDataManager);
}
```

## Example

See [json_parser_generator](../json_parser/json_parser_generator) package for real-world example.

You may also want to check out the following package for more info.
These are official foundational packages for building builder/generator packages and this library is
built on top of them.

- [build](https://pub.dev/packages/build)
  The core build system package. It provides `Builder`, `BuildStep`, asset access, resolvers, and
  the execution model used by generator packages.
- [analyzer](https://pub.dev/packages/analyzer)
  The Dart code analysis model underneath most generators. Use it when you need to inspect
  `ClassElement`, `LibraryElement`, constructors, types, annotations, and other AST/semantic data.
- [source_gen](https://pub.dev/packages/source_gen)
  A higher-level layer on top of `build` and `analyzer` for annotation-driven generation. It gives
  you helpers like `Generator`, `LibraryReader`, `AnnotatedElement`, and `TypeChecker`.
- [build_config](https://pub.dev/packages/build_config)
  Defines how builders are configured in `build.yaml`, including targets, options, and
  `build_extensions`.
- [build_runner](https://pub.dev/packages/build_runner)
  The runner used during development to execute builders, rebuild outputs, and manage the asset
  graph locally.
- [build_test](https://pub.dev/packages/build_test)
  Test utilities for verifying builder behavior, generated outputs, and build graph interactions.
- [code_builder](https://pub.dev/packages/code_builder)
  A structured way to generate Dart code programmatically instead of building long raw strings.
- [dart_style](https://pub.dev/packages/dart_style)
  Formats generated Dart source before it is written to disk.
- [glob](https://pub.dev/packages/glob)
  Useful for matching groups of input assets such as `lib/**/*.dart` while scanning a package.
- [path](https://pub.dev/packages/path)
  Normalizes and joins filesystem paths in a platform-safe way, which is especially useful for
  builder config and generated output paths.
- [yaml](https://pub.dev/packages/yaml)
  Useful when you need to read or interpret YAML-based configuration such as custom project files or
  parts of `build.yaml`.

## License

Click [here](../LICENSE) to see the license.
