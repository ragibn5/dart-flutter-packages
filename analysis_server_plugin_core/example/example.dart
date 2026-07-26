// Minimal example of an analyzer plugin built with
// `analysis_server_plugin_core`.
//
// This file shows the shape of a simple plugin developed with this library:
// 1. expose a top-level `plugin` via [PluginBuilder.
// 2. define plugin-specific config.
// 3. load that config through [ContextConfigLoader].
// 4. implement rule logic with [SessionManagedAnalysisRule].

// ignore_for_file: lines_longer_than_80_chars, unnecessary_lambdas

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:path/path.dart' as path;

/// #### Step 1: Expose a top-level `plugin`
///
/// The analysis server looks for a top-level variable named `plugin`.
/// [PluginBuilder] handles session management internally — a single
/// [SessionDataManager] is created and shared across all rules.
final plugin =
    PluginBuilder<ExampleConfig>(name: 'ExamplePlugin', configLoader: ExampleConfigLoader())
        .addLintRule((sessionDataManager) => ExampleAnnotatedModelRule(sessionDataManager))
        .build();

/// #### Step 2: Define your plugin config
///
/// Every plugin-specific config object extends [ContextConfig].
///
/// The base class exists to keep the cross-cutting data in one place:
/// - [packageInfo] tells rules which package is currently being analyzed.
/// - [scanConfig] specifies the predefined locations where the analyzer
///   should run.
/// - [logConfig] specifies the logger configuration that controls whether
///   a log of a particular level is written to the destination (file/console).
///
/// Extra fields are whatever your plugin needs.
///
/// In this example, the rule only needs the expected annotation name.
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
/// A [ContextConfigLoader] is used to construct a plugin-specific config
/// object.
///
/// You may use the params passed through the [loadPluginConfig] method
/// (i.e., the analysis context, and the pre-calculated `packageInfo`),
/// and anything else you need (e.g., reading a specific YAML config file)
/// to construct your config.
///
/// The core loader already extracts [PackageInfo] from the current analysis
/// context. This subclass only fills in plugin-specific defaults. In a real
/// plugin this is the place where you would usually read a YAML file from the
/// package root and map it into [ExampleConfig].
class ExampleConfigLoader extends ContextConfigLoader<ExampleConfig> {
  @override
  ExampleConfig loadPluginConfig(RuleContext context, PackageInfo packageInfo) {
    return ExampleConfig(
      packageInfo: packageInfo,
      logConfig: LogConfig(
        enabled: true,
        allowInfoLog: true,
        logDirectoryRelativePathFromProjectRoot: path.joinAll([
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
/// [SessionManagedAnalysisRule] exists so that rule authors do not
/// have to do the following things repeatedly for each visited file:
/// - Load typed config.
/// - Build logger with proper config applied to it, which you can use
///   throughout the analysis session.
/// - Skip analysis of the current context (file/compilation-unit)
///   if not required, as defined by [ScanConfig].
///
/// See [SessionManagedAnalysisRule] for more details.
class ExampleAnnotatedModelRule
    extends SessionManagedAnalysisRule<ExampleConfig> {
  static const code = LintCode(
    'example_annotated_model_rule',
    'Classes annotated with @{0} must be public.',
    correctionMessage: 'Rename the class so that it does not start with `_`.',
  );

  ExampleAnnotatedModelRule(SessionDataManager sessionDataManager)
    : super(RuleMetadata(code.name, code.problemMessage), sessionDataManager);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerSessionedNodeProcessors(
    RuleContext context,
    RuleVisitorRegistry registry,
    RuleSessionContext<ExampleConfig> sessionContext,
  ) {
    // Logging is available on every invocation through the session context.
    // This is useful for debugging across an analysis session.
    sessionContext.logger.logInfo(
      tag: '$ExampleAnnotatedModelRule',
      message:
          'Registering class visitor for ${context.definingUnit.file.path}',
    );

    // Pass the [RuleSessionContext] instance to the visitor so it can use
    // the same config and logger.
    registry.addClassDeclaration(
      this,
      _AnnotatedModelVisitor(rule: this, sessionContext: sessionContext),
    );
  }
}

/// #### Step 5: Write the AST visitor
///
/// Visitors contain the actual AST logic, and it is the place where you
/// report anomalies found during analysis.
///
/// You may pass the [RuleSessionContext] instance here to use the
/// [RuleSessionContext.config] and the [RuleSessionContext.logger].
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
      // Not marked, we may return - nothing to report.
      return;
    }

    if (!node.name.lexeme.startsWith('_')) {
      // Already a public class - nothing to report.
      return;
    }

    // We can use the logger passed through the session context here, too.
    sessionContext.logger.logWarning(
      tag: '$_AnnotatedModelVisitor',
      message: 'Invalid annotated model: ${node.name.lexeme}',
      extras: {'className': node.name.lexeme},
    );

    // Report the diagnostic.
    // We may pass arguments which will be matched against the
    // argument-placeholders within the `problemMessage` field.
    //
    // For example, the problemMessage was
    // `Classes annotated with @{0} must be public.`,
    // So, the final message you will see is
    // `Classes annotated with @DomainModel must be public.`.
    //
    // The numbers within the curly braces represent the index of the
    // arguments passed here.
    rule.reportAtNode(
      node,
      arguments: [sessionContext.config.requiredAnnotationName],
    );
  }

  bool _isMarkedWithTargetAnnotation(ClassDeclaration node) {
    for (final annotation in node.metadata) {
      final annotationName = annotation.name.name;
      if (annotationName == sessionContext.config.requiredAnnotationName) {
        return true;
      }
    }
    return false;
  }
}
