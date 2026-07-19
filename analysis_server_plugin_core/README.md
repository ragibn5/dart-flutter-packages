# analysis_server_plugin_core

Core components to build a custom Dart analysis server plugin.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  analysis_server_plugin_core: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  analysis_server_plugin_core:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: analysis_server_plugin_core
      ref: analysis_server_plugin_core-1.0.0
```

## Why This Package Exists

Building a Dart analysis server plugin from scratch means writing the same infrastructure every time: loading config, setting up debugging (one of the most useful parts since you cannot debug analyzer plugins directly), managing analysis sessions and session-scoped data, and wiring up the rule lifecycle. The official `analysis_server_plugin` gives you the basic APIs but not the surrounding plumbing. This library handles all of that so you can focus on the rule logic itself.

## How It Helps

- **Consistent rule lifecycle.** Every rule extends `SessionManagedAnalysisRule`, so config loading, logging, and session setup follow the same pattern across your entire plugin.
- **Shared session state.** A single `SessionDataManager` caches config and loggers per package per analysis session, so multiple rules in the same plugin don't repeat work.
- **Flexible configuration.** Extend `ContextConfig` with your own fields and load them from YAML or any other source through `ContextConfigLoader`.
- **Built-in file logging.** Every rule gets a `SessionLogger` with level-aware file logging, per-level toggles, and an `extras` map for attaching debug context -- ready to use, no setup required.
- **Declarative scan scope.** Skip `lib/`, `test/`, or both through `ScanConfig` instead of writing directory checks in every rule.

## Quick Start

A minimal plugin has six pieces. Each step below builds on the previous one.

### 1. Entry point

The Dart analysis server looks for a top-level variable named `plugin` of type extending `Plugin` (from `analysis_server_plugin` package - see next step).

This is where you create the `SessionDataManager` -- the shared store that holds your config, logger, and other session-managed components – per package, per analysis session. One instance, passed to every rule.

```dart

final plugin = MyPlugin(
  SessionDataManagerFactory.createNewInstance(MyConfigLoader()),
);
```

### 2. Plugin class

The plugin class identifies your library to the analysis server and registers rules. Extend `Plugin` (from `analysis_server_plugin` package) and use `PluginRegistry` to register each rule.

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

Your plugin's configuration extends `ContextConfig`, which already bundles `PackageInfo`, `LogConfig`, and `ScanConfig`. Add your own fields on top – anything your rules need.

The `toMap()` method is used for debugging and logging. You may want to override it to include your own fields, as well as the base class fields.

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

The config loader reads your plugin's configuration from wherever you want. This can be anything – like pubspec.yaml, standalone YAML file per plugin (recommended), or any other source you want. Extend `ContextConfigLoader` and implement `loadPluginConfig`. The base class already extracts `PackageInfo` from `pubspec.yaml` for you.

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

The rule extends `SessionManagedAnalysisRule`, which handles the session lifecycle for you – loading config, creating debug setup, setting up session data, and caching everything per package, per analysis session. You implement `registerSessionedNodeProcessors`, which receives a `RuleSessionContext` with the resolved config, logger, and other session-managed data – ready to use.

The `LintCode` supports argument interpolation: `{0}`, `{1}`, etc. in `problemMessage` are replaced with the values you pass when reporting a diagnostic.

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

The visitor contains the actual AST analysis logic. It receives the `RuleSessionContext` so it can access both the typed config and the logger. Use the reporting methods within the `AnalysisRule` instance to emit diagnostics that show up in the IDE and in `dart analyze` output.

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

| Class                   | Purpose                                                                                                                             |
|-------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| `ContextConfig`         | Abstract base for plugin-specific configuration. Bundles `PackageInfo`, `LogConfig`, and `ScanConfig`. Extend with your own fields. |
| `PackageInfo`           | Package name and root path for the currently analyzed package.                                                                      |
| `LogConfig`             | Controls whether logging is enabled, which levels are allowed, and where log files are written.                                     |
| `ScanConfig`            | Controls whether `lib/`, `test/`, or both are scanned.                                                                              |
| `RuleMetadata`          | Name and description for a rule.                                                                                                    |
| `RuleSessionContext<T>` | Wraps a resolved config and a logger. Passed to your rule visitors.                                                                 |
| `Mappable`              | Interface requiring `toMap()` for serializable config maps.                                                                         |

### Rules

| Class                           | Purpose                                                                                                                                                                                   |
|---------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `SessionManagedAnalysisRule<T>` | Abstract rule that automates session lifecycle. Handles config loading, session caching, logger creation, and scan-scope checks before delegating to `registerSessionedNodeProcessors()`. |

### Services

| Area        | Class                       | Purpose                                                                                                           |
|-------------|-----------------------------|-------------------------------------------------------------------------------------------------------------------|
| **Config**  | `ContextConfigLoader<T>`    | Abstract loader. Subclass it to extract `PackageInfo` from a `RuleContext` and build your plugin-specific config. |
| **Session** | `SessionDataManager`        | Caches `SessionData` per package per analysis session. Returns cache-hit or newly-created results.                |
| **Session** | `SessionDataManagerFactory` | Static factory that wires the session data pipeline together. Pass it your `ContextConfigLoader`.                 |
| **Logger**  | `SessionLogger`             | Interface for level-aware logging (info/warning/error) with global and per-level toggles.                         |

### Helpers

| What                                     | Purpose                                                                                                        |
|------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `AnnotationTypeResolver`                 | Resolves an `Annotation` AST node to its class name, handling const values and typedef aliases.                |
| `CollectionTypeResolver`                 | Checks whether a `TypeAnnotation` is `List<T>` or `Map<K,V>`, with nullability matching and typedef support.   |
| `PathStringExtensions` on `String`       | `normalizePathSeparators`, `ensureTrailingPathSeparator`, `surroundingPathSeparator` for cross-platform paths. |
| `RuleContextExtensions` on `RuleContext` | `packageRelativeUnitPath` getter for file paths relative to the package root.                                  |
| `AnalyzerFile` / `AnalyzerFolder`        | Typedefs for `analyzer.file_system.File` and `analyzer.file_system.Folder`.                                    |

## Example

See the full [example](example/example.dart) for detailed comments on each step, or look at real plugins built with this library:

- [clean_arch_lint](../clean_arch_lint)
- [json_parser_analyzer](../json_parser/json_parser_analyzer)