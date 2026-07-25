// Example of an analyzer plugin built with `PluginBuilder`.
//
// This file shows the builder-based shape of a plugin:
// 1. define plugin-specific config,
// 2. load that config through [ContextConfigLoader],
// 3. implement rule logic with [SessionManagedAnalysisRule],
// 4. wire everything together with [PluginBuilder].

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:path/path.dart' as path;

/// #### Step 1: Expose a top-level `plugin`
///
/// The analysis server looks for a top-level variable named `plugin`.
/// [PluginBuilder] handles the wiring internally — a single
/// [SessionDataManager] is created and shared across all rules.
final plugin = PluginBuilder<ExampleConfig>(
  name: 'ExamplePlugin',
  configLoader: ExampleConfigLoader(),
)
  .addLintRule(ExampleAnnotatedModelRule.new)
  .build();

/// #### Step 2: Define your plugin config
///
/// Every plugin-specific config object extends [ContextConfig].
///
/// The base class bundles cross-cutting data:
/// - [packageInfo] — which package is being analyzed.
/// - [scanConfig] — where the analyzer should run.
/// - [logConfig] — logger output control.
///
/// Extra fields are whatever your plugin needs.
class ExampleConfig extends ContextConfig {
  final String requiredAnnotationName;

  const ExampleConfig({
    required super.packageInfo,
    required super.logConfig,
    required super.scanConfig,
    this.requiredAnnotationName = 'DomainModel',
  });

  @override
  Map<String, dynamic> toMap() => {
    'packageInfo': packageInfo.toMap(),
    'logConfig': logConfig.toMap(),
    'scanConfig': scanConfig.toMap(),
    'requiredAnnotationName': requiredAnnotationName,
  };
}

/// #### Step 3: Load config for each analyzed package
///
/// Extend [ContextConfigLoader] and implement
/// [loadPluginConfig]. The base class extracts
/// [PackageInfo] from `pubspec.yaml` for you.
class ExampleConfigLoader extends ContextConfigLoader<ExampleConfig> {
  @override
  ExampleConfig loadPluginConfig(
    RuleContext context,
    PackageInfo packageInfo,
  ) {
    return ExampleConfig(
      packageInfo: packageInfo,
      logConfig: LogConfig(
        enabled: true,
        allowInfoLog: true,
        logDirectoryRelativePathFromProjectRoot:
            path.joinAll([
              'logs',
              'analyzer_plugins',
              'example_plugin',
            ]),
      ),
      scanConfig: const ScanConfig(),
    );
  }
}

/// #### Step 4: Implement a session-managed rule
///
/// [SessionManagedAnalysisRule] handles config loading,
/// session caching, and scan filtering before calling
/// [registerSessionedNodeProcessors].
class ExampleAnnotatedModelRule
    extends SessionManagedAnalysisRule<ExampleConfig> {
  static const code = LintCode(
    'example_annotated_model_rule',
    'Classes annotated with @{0} must be public.',
    correctionMessage:
        'Rename the class so that it does not start '
        'with `_`.',
  );

  ExampleAnnotatedModelRule(
    SessionDataManager sessionDataManager,
  ) : super(
         RuleMetadata(code.name, code.problemMessage),
         sessionDataManager,
       );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerSessionedNodeProcessors(
    RuleContext context,
    RuleVisitorRegistry registry,
    RuleSessionContext<ExampleConfig> sessionContext,
  ) {
    sessionContext.logger.logInfo(
      tag: '$ExampleAnnotatedModelRule',
      message:
          'Registering class visitor for '
          '${context.definingUnit.file.path}',
    );

    registry.addClassDeclaration(
      this,
      _AnnotatedModelVisitor(
        rule: this,
        sessionContext: sessionContext,
      ),
    );
  }
}

/// #### Step 5: Write the AST visitor
///
/// Visitors contain the actual AST logic. Use [rule] to
/// report diagnostics and [sessionContext] for config and
/// logging access.
class _AnnotatedModelVisitor extends SimpleAstVisitor<void> {
  final ExampleAnnotatedModelRule rule;
  final RuleSessionContext<ExampleConfig> sessionContext;

  const _AnnotatedModelVisitor({
    required this.rule,
    required this.sessionContext,
  });

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!_isMarkedWithTargetAnnotation(node)) {
      return;
    }

    if (!node.name.lexeme.startsWith('_')) {
      return;
    }

    sessionContext.logger.logWarning(
      tag: '$_AnnotatedModelVisitor',
      message:
          'Invalid annotated model: ${node.name.lexeme}',
      extras: {'className': node.name.lexeme},
    );

    rule.reportAtNode(
      node,
      arguments: [
        sessionContext.config.requiredAnnotationName,
      ],
    );
  }

  bool _isMarkedWithTargetAnnotation(
    ClassDeclaration node,
  ) {
    for (final annotation in node.metadata) {
      final annotationName = annotation.name.name;
      if (annotationName ==
          sessionContext.config.requiredAnnotationName) {
        return true;
      }
    }
    return false;
  }
}
