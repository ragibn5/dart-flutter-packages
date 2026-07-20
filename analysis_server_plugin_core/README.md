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

Building a Dart analysis server plugin from scratch means writing the same infrastructure every time: loading config, setting up debugging (especially useful since you cannot debug analyzer plugins directly), managing analysis sessions, and wiring up the rule lifecycle. The official `analysis_server_plugin` gives you the basic APIs but not the plumbing. This library handles all of that so you can focus on rule logic.

## How It Helps

- **Consistent rule lifecycle.** Every rule extends `SessionManagedAnalysisRule`, so config loading, logging, and session setup follow the same pattern.
- **Shared session state.** A single `SessionDataManager` caches config and loggers per package per session, so rules don't repeat work.
- **Flexible configuration.** Extend `ContextConfig` with your own fields and load them from YAML or any source through `ContextConfigLoader`.
- **Built-in file logging.** Every rule gets a `SessionLogger` with level-aware file logging, per-level toggles, and an `extras` map for debug context.
- **Declarative scan scope.** Skip `lib/`, `test/`, or both through `ScanConfig` instead of writing directory checks in every rule.

## Quick Start

A minimal plugin has six pieces. Each step builds on the previous one.

### 1. Entry point

The Dart analysis server looks for a top-level variable named `plugin` of a type extending `Plugin` (from `analysis_server_plugin` — see next step).

This is where you create the `SessionDataManager` — the shared store for config, logger, and other session-managed components.

```dart

final plugin = MyPlugin(
  SessionDataManagerFactory.createNewInstance(MyConfigLoader()),
);
```

### 2. Plugin class

The plugin class identifies your library to the analysis server and registers rules. Extend `Plugin` (from `analysis_server_plugin`) and use `PluginRegistry` to register each rule.

```dart
class MyPlugin extends Plugin {
  final SessionDataManager _sessionDataManager;

  MyPlugin(this._sessionDataManager);

  @override
  String get name => 'MyPlugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(MyRule(_sessionDataManager));
  }
}
```

### 3. Config

Your plugin's configuration extends `ContextConfig`, which bundles `PackageInfo`, `LogConfig`, and `ScanConfig`. Add your own fields on top.

The `toMap()` method is used for debugging and logging. Override it to include your own fields and the base class fields.

```dart
class MyConfig extends ContextConfig {
  final String annotationName;

  const MyConfig({
    required super.packageInfo,
    required super.logConfig,
    required super.scanConfig,
    this.annotationName = 'MyAnnotation',
  });

  @override
  Map<String, dynamic> toMap() =>
      {
        'packageInfo': packageInfo.toMap(),
        'logConfig': logConfig.toMap(),
        'scanConfig': scanConfig.toMap(),
        'annotationName': annotationName,
      };
}
```

### 4. Config loader

The config loader reads your plugin's configuration from any source — pubspec.yaml, a standalone YAML file per plugin (recommended), or anything else. Extend `ContextConfigLoader` and implement `loadPluginConfig`. The base class extracts `PackageInfo` from `pubspec.yaml` for you.

```dart
class MyConfigLoader extends ContextConfigLoader<MyConfig> {
  @override
  MyConfig loadPluginConfig(RuleContext context, PackageInfo packageInfo) {
    return MyConfig(
      packageInfo: packageInfo,
      logConfig: LogConfig(
        enabled: true,
        logDirectoryRelativePathFromProjectRoot: 'logs/analyzer_plugins/my_plugin',
      ),
      scanConfig: const ScanConfig(),
    );
  }
}
```

### 5. Rule

The rule extends `SessionManagedAnalysisRule`, which handles the session lifecycle — loading config, creating debug setup, and caching session data per package. You implement `registerSessionedNodeProcessors`, which receives a `RuleSessionContext` with the resolved config, logger, and session-managed data.

`LintCode` supports argument interpolation: `{0}`, `{1}`, etc. in `problemMessage` are replaced with your arguments when reporting a diagnostic.

```dart
class MyRule extends SessionManagedAnalysisRule<MyConfig> {
  static const code = LintCode(
    'my_rule',
    'Classes annotated with @{0} must be public.',
  );

  MyRule(SessionDataManager sessionDataManager)
      : super(RuleMetadata(code.name, code.problemMessage), sessionDataManager);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerSessionedNodeProcessors(RuleContext context,
      RuleVisitorRegistry registry,
      RuleSessionContext<MyConfig> sessionContext) {
    registry.addClassDeclaration(
      this,
      _MyVisitor(rule: this, sessionContext: sessionContext),
    );
  }
}
```

### 6. Visitor

The visitor contains the AST analysis logic. It receives `RuleSessionContext` to access the typed config and logger. Use the reporting methods on the `AnalysisRule` instance to emit diagnostics in the IDE and `dart analyze` output.

```dart
class _MyVisitor extends SimpleAstVisitor<void> {
  final MyRule rule;
  final RuleSessionContext<MyConfig> sessionContext;

  _MyVisitor({required this.rule, required this.sessionContext});

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final hasAnnotation = node.metadata.any(
          (a) => a.name.name == sessionContext.config.annotationName,
    );
    if (!hasAnnotation) return;
    if (node.name.lexeme.startsWith('_')) {
      rule.reportAtNode(node, arguments: [sessionContext.config.annotationName]);
    }
  }
}
```

## Components

### Models

| Class                   | Purpose                                                                                                                    |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------|
| `ContextConfig`         | Abstract base for plugin configuration. Bundles `PackageInfo`, `LogConfig`, and `ScanConfig`. Extend with your own fields. |
| `PackageInfo`           | Package name and root path for the currently analyzed package.                                                             |
| `LogConfig`             | Controls whether logging is enabled, which levels are allowed, and where log files are written.                            |
| `ScanConfig`            | Controls whether `lib/`, `test/`, or both are scanned.                                                                     |
| `RuleMetadata`          | Name and description for a rule.                                                                                           |
| `RuleSessionContext<T>` | Wraps a resolved config and a logger. Passed to your rule visitors.                                                        |
| `Mappable`              | Interface requiring `toMap()` for serializable config maps.                                                                |

### Rules

| Class                           | Purpose                                                                                                                                                                               |
|---------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `SessionManagedAnalysisRule<T>` | Abstract rule automating session lifecycle. Handles config loading, session caching, logger creation, and scan-scope checks before delegating to `registerSessionedNodeProcessors()`. |

### Services

| Area        | Class                       | Purpose                                                                                        |
|-------------|-----------------------------|------------------------------------------------------------------------------------------------|
| **Config**  | `ContextConfigLoader<T>`    | Abstract loader. Subclass to extract `PackageInfo` from a `RuleContext` and build your config. |
| **Session** | `SessionDataManager`        | Caches `SessionData` per package per session. Returns cache-hit or newly-created results.      |
| **Session** | `SessionDataManagerFactory` | Static factory that wires the session data pipeline. Pass it your `ContextConfigLoader`.       |
| **Logger**  | `SessionLogger`             | Interface for level-aware logging (info/warning/error) with global and per-level toggles.      |

### Helpers

| What                                     | Purpose                                                                                                        |
|------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `AnnotationTypeResolver`                 | Resolves an `Annotation` AST node to its class name, handling const values and typedef aliases.                |
| `CollectionTypeResolver`                 | Checks whether a `TypeAnnotation` is `List<T>` or `Map<K,V>`, with nullability matching and typedef support.   |
| `PathStringExtensions` on `String`       | `normalizePathSeparators`, `ensureTrailingPathSeparator`, `surroundingPathSeparator` for cross-platform paths. |
| `RuleContextExtensions` on `RuleContext` | `packageRelativeUnitPath(pathSeparator:)` for file paths relative to the package root.                         |
| `AnalyzerFile` / `AnalyzerFolder`        | Typedefs for `analyzer.file_system.File` and `analyzer.file_system.Folder`.                                    |

## Example

See the full [example](example/example.dart), or look at real plugins built with this library:

- [clean_arch_linter](https://pub.dev/packages/clean_arch_linter) | [source](../clean_arch_linter)
- [json_parser_analyzer](https://pub.dev/packages/json_parser_analyzer) | [source](../json_parser/json_parser_analyzer)
