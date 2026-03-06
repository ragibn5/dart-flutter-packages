import 'package:analysis_server_core/src/models/context_config.dart';
import 'package:analysis_server_core/src/models/rule_metadata.dart';
import 'package:analysis_server_core/src/models/rule_session_context.dart';
import 'package:analysis_server_core/src/services/session/session_data_manager.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:meta/meta.dart';

abstract class SessionManagedAnalysisRule<T extends ContextConfig>
    extends AnalysisRule {
  final RuleMetadata metadata;
  final SessionDataManager sessionDataManager;

  SessionManagedAnalysisRule(this.metadata, this.sessionDataManager)
    : super(name: metadata.name, description: metadata.description);

  /// Register processors for the node being analyzed.
  ///
  /// The provided [sessionContext] is guaranteed to contain
  /// a resolved configuration, and a logger to log necessary
  /// events.
  ///
  /// **Note,**
  /// This method will not be called if the node is filtered
  /// out by lint configuration, or in any erroneous cases.
  void registerSessionedNodeProcessors(
    RuleContext context,
    RuleVisitorRegistry registry,
    RuleSessionContext<T> sessionContext,
  );

  @override
  @mustCallSuper
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final sessionDataFetchResult = sessionDataManager.getSessionDataFor(
      context,
    );
    final sessionData = sessionDataFetchResult.sessionData;
    final logger = sessionData.logger;
    final config = sessionData.config;
    final scanConfig = config.scanConfig;
    final srcPath = context.definingUnit.file.path;
    if (sessionDataFetchResult.isNewlyCreated) {
      sessionData.logger.logInfo(
        tag: '$SessionDataManager',
        message: 'Starting session with config:',
        extras: sessionData.config.toMap(),
      );
    }

    if (config is! T) {
      logger.logWarning(
        tag: '$SessionManagedAnalysisRule',
        message:
            'Config type mismatch. '
            'Expected $T, got ${config.runtimeType}. '
            'Ensure correct SessionDataFactory is registered for this plugin.',
      );
      return;
    }

    if (context.isInLibDir && !scanConfig.scanLibDir) {
      logger.logInfo(
        tag: '$SessionManagedAnalysisRule',
        message: 'lib/ scanning disabled, skipping: $srcPath',
      );
      return;
    }

    if (context.isInTestDirectory && !scanConfig.scanTestDir) {
      logger.logInfo(
        tag: '$SessionManagedAnalysisRule',
        message: 'test/ scanning disabled, skipping: $srcPath',
      );
      return;
    }

    registerSessionedNodeProcessors(
      context,
      registry,
      RuleSessionContext(config: config, logger: logger),
    );
  }
}
