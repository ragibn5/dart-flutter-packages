import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/models/json_parser_lint_config.dart';
import 'package:json_parser_analyzer/rules/json_parser_requirement_rule/json_parser_requirement_visitor.dart';

class JsonParserRequirementRule
    extends SessionManagedAnalysisRule<JsonParserLintConfig> {
  static const LintCode JPR_LINT_CODE = LintCode(
    'json_parser_requirements',
    'Missing or invalid components for JSON parser generation: {0}',
    correctionMessage: '''
    The class should contain following component(s) in order for the
    generator to generate the parser(s) & registry(s):
    - Map<String, dynamic> toJson() { ... }
    - YourClass fromJson(Map<String, dynamic> json) { ... }
    ''',
    severity: DiagnosticSeverity.ERROR,
  );

  JsonParserRequirementRule(SessionDataManager sessionDataManager)
    : super(
        RuleMetadata(JPR_LINT_CODE.name, JPR_LINT_CODE.problemMessage),
        sessionDataManager,
      );

  @override
  DiagnosticCode get diagnosticCode => JPR_LINT_CODE;

  @override
  void registerSessionedNodeProcessors(
    RuleContext context,
    RuleVisitorRegistry registry,
    RuleSessionContext<JsonParserLintConfig> sessionContext,
  ) {
    final srcPath = context.definingUnit.file.path;

    sessionContext.logger.logInfo(
      tag: '$JsonParserRequirementRule',
      message: 'Registering $JsonParserRequirementRuleVisitor for: $srcPath',
    );

    registry.addAnnotation(
      this,
      JsonParserRequirementRuleVisitor(this, sessionContext),
    );
  }
}
