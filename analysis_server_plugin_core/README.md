# analysis_server_plugin_core

Core components to build a custom Dart analysis server plugin.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  analysis_server_plugin_core: ^1.0.1
```

#### Or, From Git repo

```yaml
dependencies:
  analysis_server_plugin_core:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: analysis_server_plugin_core
      ref: analysis_server_plugin_core-1.0.1
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

The core idea is straightforward:

- write your config own model
- write a config loader that loads the config
- Write rules and visitors for processing those rules

And, the package handles the repeated infrastructure around them.

## 🚀 Quick start

This is the shape of a small analyzer plugin built with the package.

### 1. Build the plugin

The analysis server looks for a top-level variable named `plugin`. For example,

```dart
import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';

final plugin = PluginBuilder<ExampleConfig>(
  name: 'ExamplePlugin',
  configLoader: ExampleConfigLoader(),
  rules: [ExampleRule.new],
).build();
```

Use `PluginBuilder` to build the plugin. It requires the following:

- `name`: Name of the plugin being created – used by the Dart analysis server to identify the plugin.
- `configLoader`: A `ContextConfigLoader` instance that produces the plugin's config for each analyzed package.
- `rules`: A list of `SessionedRuleFactory` functions. Each receives a shared `SessionDataManager` and returns a rule instance. Pass an empty list if the plugin has no rules yet.

See the next steps to know how we create each of these.

### 2. Define plugin config

Define a config class extending `ContextConfig`, which bundles `PackageInfo`, `LogConfig`, and `ScanConfig`. Add your own fields on top.

The `toMap()` method is used for debugging and logging. Override it to include your own fields and the base class fields.

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

The config loader reads your plugin's configuration from any source — pubspec.yaml, a standalone YAML file per plugin (recommended), or anything else. Extend `ContextConfigLoader` and implement `loadPluginConfig`. The base class extracts `PackageInfo` from `pubspec.yaml` for you.

```dart
class ExampleConfigLoader extends ContextConfigLoader<ExampleConfig> {
  @override
  ExampleConfig loadPluginConfig(RuleContext context,
      PackageInfo packageInfo,) {
    return ExampleConfig(
      packageInfo: packageInfo,
      logConfig: const LogConfig(
        enabled: true,
        allowInfoLog: true,
        logDirectoryRelativePathFromProjectRoot: 'logs/analyzer_plugins/example',
      ),
      scanConfig: const ScanConfig(
        scanLibDir: true,
        scanTestDir: false,
      ),
    );
  }
}
```

### 4. Write a session-managed rule

Define rule classes extending `SessionManagedAnalysisRule<T>`. Your `registerSessionedNodeProcessors` method runs only after:

- config has been loaded
- debug setup has been created
- the config type has been verified
- the current file passes `ScanConfig`

```dart
class ExampleRule extends SessionManagedAnalysisRule<ExampleConfig> {
  static const code = LintCode(
    'example_rule',
    'Classes annotated with @{0} must be public.',
  );

  ExampleRule(SessionDataManager sessionDataManager)
      : super(RuleMetadata(code.name, code.problemMessage), sessionDataManager);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerSessionedNodeProcessors(RuleContext context,
      RuleVisitorRegistry registry,
      RuleSessionContext<ExampleConfig> sessionContext) {
    registry.addClassDeclaration(
      this,
      _ExampleVisitor(rule: this, sessionContext: sessionContext),
    );
  }
}
```

`LintCode` message arguments work as usual. In this example, `{0}` becomes the configured annotation name when the diagnostic is reported.

### 6. Visitor

The visitor contains the AST analysis logic. It receives `RuleSessionContext` to access the typed config and logger. Use the reporting methods on the `AnalysisRule` instance to emit diagnostics in the IDE and `dart analyze` output.

```dart
class _ExampleVisitor extends SimpleAstVisitor<void> {
  final ExampleRule rule;
  final RuleSessionContext<ExampleConfig> sessionContext;

  const _ExampleVisitor({
    required this.rule,
    required this.sessionContext,
  });

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final annotationName = sessionContext.config.requiredAnnotationName;
    final hasAnnotation = node.metadata.any(
          (annotation) => annotation.name.name == annotationName,
    );

    if (hasAnnotation && node.name.lexeme.startsWith('_')) {
      sessionContext.logger.logWarning(
        tag: 'ExampleRule',
        message: 'Private annotated class: ${node.name.lexeme}',
      );
      rule.reportAtNode(node, arguments: [annotationName]);
    }
  }
}
```

## 🧰 Utilities

The package also exports small helpers useful when writing analyzer rules.

### Resolve annotations

`AnnotationTypeResolver` uses analyzer constant evaluation, so it can resolve direct annotations, const variables, and typedef aliases.

```dart

final annotationResolver = AnnotationTypeResolverFactory.create();
final annotationType = annotationResolver.resolveTypeName(annotation);
```

### Match collection types

`CollectionTypeResolver` checks exact `List<T>` and `Map<K, V>` types using analyzer type information. It supports typedef aliases and strict nullability matching.

```dart

final collectionResolver = CollectionTypeResolverFactory.create();
final isStringList = collectionResolver.isListOf(
  returnType,
  valueType: 'String',
);

final isJsonMap = collectionResolver.isMapOf(
  returnType,
  keyType: 'String',
  valueType: 'dynamic',
);
```

### Work with paths

```dart

final relativePath = context.packageRelativeUnitPath(pathSeparator: '/');
final normalized = r'lib\src\rule.dart'.normalizePathSeparators(
  pathSeparator: '/',
);
```

## 📦 API

Everything commonly needed is exported from one import:

```dart
import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
```

| Component                       | Purpose                                                                                   |
|---------------------------------|-------------------------------------------------------------------------------------------|
| `PluginBuilder<C>`              | Type-safe builder that wires config loader, rules, and session manager into a `Plugin`.   |
| `SessionedRuleFactory<C>`       | A function that creates a rule from a shared `SessionDataManager`.                        |
| `SessionManagedAnalysisRule<T>` | Base class for rules that need typed config, logging, session reuse, and scan filtering.  |
| `ContextConfig`                 | Base config model. Extend it with plugin-specific options.                                |
| `ContextConfigLoader<T>`        | Loads config and resolves package metadata for the current `RuleContext`.                 |
| `RuleSessionContext<T>`         | The object your visitors use to access typed config and the session logger.               |
| `RuleMetadata`                  | Rule identity (code name and problem message).                                            |
| `PackageInfo`                   | Package name and root path; falls back safely for standalone files.                       |
| `LogConfig`                     | Enables/disables file logging and individual info/warning/error levels.                   |
| `ScanConfig`                    | Controls whether `lib/` and `test/` are scanned. Defaults to `lib: true`, `test: false`.  |
| `SessionDataManager`            | Caches `SessionData` per package root.                                                    |
| `SessionLogger`                 | Session logger with global and per-level switches.                                        |
| `AnnotationTypeResolver`        | Resolves annotation class names through constant values.                                  |
| `AnnotationTypeResolverFactory` | Creates an [AnnotationTypeResolver].                                                      |
| `CollectionTypeResolver`        | Matches exact `List<T>` and `Map<K, V>` annotations with typedef and nullability support. |
| `CollectionTypeResolverFactory` | Creates a [CollectionTypeResolver].                                                       |
| `PathStringExtensions`          | Normalizes, appends, and surrounds path separators.                                       |
| `RuleContextExtensions`         | Converts the current unit path to a package-relative path.                                |

## 🧪 Examples

See [example.dart](example/example.dart) for a minimal analyzer plugin using typed config, session logging, and one lint rule.

Real plugins built with this package:

- [clean_arch_linter](https://pub.dev/packages/clean_arch_linter) | [source](../clean_arch_linter)
- [json_parser_linter](https://pub.dev/packages/json_parser_linter) | [source](../json_parser/json_parser_linter)
