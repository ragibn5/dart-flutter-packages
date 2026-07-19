import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/extensions/string_extensions.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/rules/dependency_direction_rule/dependency_direction_rule_visitor.dart';

class DependencyDirectionRule
    extends SessionManagedAnalysisRule<CleanArchLintConfig> {
  static const LintCode DDR_LINT_CODE = LintCode(
    'clean_arch_dependency_direction',
    'Inappropriate dependency in domain component: {0}',
    correctionMessage: '''
    Domain components should be as self-sufficient as possible.
  
    If you need to use an external dependency anyway (which should be
    approved by tech leads), you can allow it through the configuration
    file. Please refer to the documentation for more details.
    ''',
    severity: DiagnosticSeverity.WARNING,
  );

  DependencyDirectionRule(SessionDataManager sessionDataManager)
    : super(
        RuleMetadata(DDR_LINT_CODE.name, DDR_LINT_CODE.problemMessage),
        sessionDataManager,
      );

  @override
  DiagnosticCode get diagnosticCode => DDR_LINT_CODE;

  @override
  void registerSessionedNodeProcessors(
    RuleContext context,
    RuleVisitorRegistry registry,
    RuleSessionContext<CleanArchLintConfig> sessionContext,
  ) {
    final srcPath = context.definingUnit.file.path;

    final ddrConfig = sessionContext.config.ddrConfig;
    if (!ddrConfig.domainDirNames.containsAnyAsPathSegment(srcPath)) {
      sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRule',
        message: 'Ignoring non domain component: $srcPath',
      );
      return;
    }

    sessionContext.logger.logInfo(
      tag: '$DependencyDirectionRule',
      message: 'Registering $DependencyDirectionRuleVisitor for: $srcPath',
    );

    registry.addImportDirective(
      this,
      DependencyDirectionRuleVisitor(this, sessionContext),
    );
  }
}
