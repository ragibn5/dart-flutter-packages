# analysis_server_plugin_core

Core components to build a custom Dart analysis server plugin.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  analysis_server_plugin_core: ^1.1.1
```

#### Or, From Git repo

```yaml
dependencies:
  analysis_server_plugin_core:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: analysis_server_plugin_core
      ref: analysis_server_plugin_core-1.1.1
```

## Why This Package Exists

`analysis_server_plugin_core` is a small foundational package for writing custom Dart analyzer plugins. It sits on top of the official analyzer/plugin APIs and adds the reusable structure most real plugins need.

The official APIs give you the raw building blocks – plugins, lint rules, visitors, rule contexts, diagnostics, AST nodes, type information, and much more. This package focuses on the missing application-level layer around those APIs.

It provides:

- **Package context** — access useful metadata about the package currently being analyzed.
- **Shared plugin config** — load plugin-specific config once and reuse it across rules.
- **Typed rule context** — pass typed config and debugging setup into visitors without manual wiring.
- **Analyzer-friendly debugging** — write structured file logs from rules running inside the analysis server.
- **Consistent scan scope** — define where your rules should run without repeating checks in every rule.
- **Semantic rule helpers** — use analyzer-backed utilities for common rule logic instead of fragile manual checks.

## 🚀 Quick start

The core idea is straightforward.

- write your own config model
- write a config loader that loads the config
- Write rules and visitors for processing those rules

And, the package handles the repeated infrastructure around them. Here is how you build a minimal analyzer plugin in 5 steps:

### 1. Build the plugin

The analysis server looks for a top-level variable named `plugin`. Use `PluginBuilder` to create it.

```dart
import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';

final plugin = PluginBuilder<ExampleConfig>(name: 'ExamplePlugin', configLoader: ExampleConfigLoader())
    .addLintRule((sessionDataManager) => ExampleLintRule(sessionDataManager))
    .addWarningRule((sessionDataManager) => ExampleWarningRule(sessionDataManager))
    .build();
```

| Method             | Description                                                               |
|--------------------|---------------------------------------------------------------------------|
| `name`             | Plugin identifier reported to the Dart analysis server.                   |
| `configLoader`     | A `ContextConfigLoader` that produces config for each analyzed package.   |
| `addLintRule()`    | Registers a lint rule factory — receives the shared `SessionDataManager`. |
| `addWarningRule()` | Registers a warning rule factory — same shape as `addLintRule()`.         |

### 2. Define plugin config

Extend `ContextConfig` to bundle your plugin's settings with the built-in `PackageInfo`, `LogConfig`, and `ScanConfig`.

```dart
class ExampleConfig extends ContextConfig {
  final String requiredAnnotationName;

  const ExampleConfig({
    required super.packageInfo,
    required super.logConfig,
    required super.scanConfig,
    this.requiredAnnotationName = 'DomainModel',
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'packageInfo': packageInfo.toMap(),
        'logConfig': logConfig.toMap(),
        'scanConfig': scanConfig.toMap(),
        'requiredAnnotationName': requiredAnnotationName,
      };
}
```

### 3. Load config per package

Extend `ContextConfigLoader` and implement `loadPluginConfig`. The base class extracts `PackageInfo` from `pubspec.yaml` for you — you fill in plugin-specific values.

```dart
class ExampleConfigLoader extends ContextConfigLoader<ExampleConfig> {
  @override
  ExampleConfig loadPluginConfig(RuleContext context, PackageInfo packageInfo) {
    return ExampleConfig(
      packageInfo: packageInfo,
      logConfig: const LogConfig(
        enabled: true,
        allowInfoLog: true,
        logDirectoryRelativePathFromProjectRoot: 'logs/analyzer_plugins/example',
      ),
      scanConfig: const ScanConfig(scanLibDir: true, scanTestDir: false),
    );
  }
}
```

### 4. Write a rule

Extend `SessionManagedAnalysisRule<T>`. By the time `registerSessionedNodeProcessors` runs, config is loaded, the type is verified, and `ScanConfig` filtering is done.

```dart
class ExampleLintRule extends SessionManagedAnalysisRule<ExampleConfig> {
  static const code = LintCode(
    'example_rule',
    'Classes annotated with @{0} must be public.',
  );

  ExampleLintRule(SessionDataManager sessionDataManager)
      : super(RuleMetadata(code.name, code.problemMessage), sessionDataManager);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerSessionedNodeProcessors(RuleContext context,
      RuleVisitorRegistry registry,
      RuleSessionContext<ExampleConfig> sessionContext,) {
    registry.addClassDeclaration(
      this,
      _ExampleVisitor(rule: this, sessionContext: sessionContext),
    );
  }
}
```

### 5. Write a visitor

The visitor contains the AST analysis logic. Use `sessionContext` for config and logging, and `rule.reportAtNode()` to emit diagnostics.

```dart
class _ExampleVisitor extends SimpleAstVisitor<void> {
  final ExampleLintRule rule;
  final RuleSessionContext<ExampleConfig> sessionContext;

  const _ExampleVisitor({required this.rule, required this.sessionContext});

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final annotationName = sessionContext.config.requiredAnnotationName;
    final hasAnnotation = node.metadata.any(
          (a) => a.name.name == annotationName,
    );

    if (hasAnnotation && node.name.lexeme.startsWith('_')) {
      sessionContext.logger.logWarning(
        tag: 'ExampleLintRule',
        message: 'Private annotated class: ${node.name.lexeme}',
      );
      rule.reportAtNode(node, arguments: [annotationName]);
    }
  }
}
```

## 🧰 Utilities

### Resolve annotations

```dart

final resolver = AnnotationTypeResolverFactory.create();
final typeName = resolver.resolveTypeName(annotation);
```

### Match collection types

```dart

final resolver = CollectionTypeResolverFactory.create();
final isStringList = resolver.isListOf(returnType, valueType: 'String');
final isJsonMap = resolver.isMapOf(returnType, keyType: 'String', valueType: 'dynamic');
```

### Work with paths

```dart

final relativePath = context.packageRelativeUnitPath(pathSeparator: '/');
final normalized = r'lib\src\rule.dart'.normalizePathSeparators(pathSeparator: '/');
```

## 📦 API

Everything is exported from a single import:

```dart
import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
```

| Component                       | Purpose                                                                              |
|---------------------------------|--------------------------------------------------------------------------------------|
| `PluginBuilder<C>`              | Type-safe builder — wires config loader, rules, and session manager into a `Plugin`. |
| `SessionedRuleFactory<C>`       | Function signature: receives a `SessionDataManager`, returns a rule.                 |
| `SessionManagedAnalysisRule<T>` | Base class for rules with typed config, logging, session reuse, and scan filtering.  |
| `ContextConfig`                 | Base config model — extend with your plugin's options.                               |
| `ContextConfigLoader<T>`        | Loads config and resolves package metadata per `RuleContext`.                        |
| `RuleSessionContext<T>`         | Typed config + logger passed to visitors.                                            |
| `RuleMetadata`                  | Rule identity (code name and problem message).                                       |
| `PackageInfo`                   | Package name and root path.                                                          |
| `LogConfig`                     | Enables/disables file logging and log levels.                                        |
| `ScanConfig`                    | Controls `lib/` and `test/` scanning.                                                |
| `SessionDataManager`            | Caches session data per package.                                                     |
| `SessionDataManagerFactory`     | Creates a `SessionDataManager` (also used internally by `PluginBuilder`).            |
| `SessionLogger`                 | Logger with global and per-level switches.                                           |
| `AnnotationTypeResolver`        | Resolves annotation class names through constant values.                             |
| `CollectionTypeResolver`        | Matches `List<T>` and `Map<K, V>` with typedef and nullability support.              |
| `PathStringExtensions`          | Normalizes and manipulates path separators.                                          |
| `RuleContextExtensions`         | Converts unit paths to package-relative paths.                                       |

## 🧪 Examples

See [example.dart](example/example.dart) for a complete minimal plugin.

Real plugins built with this package:

- [clean_arch_linter](https://pub.dev/packages/clean_arch_linter) | [source](../clean_arch_linter)
- [json_parser_linter](https://pub.dev/packages/json_parser_linter) | [source](../json_parser/json_parser_linter)
