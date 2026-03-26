import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/src/models/json_parser_lint_config.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/json_parser_requirement_visitor.dart';

class JsonParserRequirementRule
    extends SessionManagedAnalysisRule<JsonParserLintConfig> {
  static const LintCode JPR_LINT_CODE = LintCode(
    'json_parser_requirements',
    'Missing or invalid components for JSON parser generation: {0}',
    correctionMessage: '''
    Ensure the class defines both of the following:
      - Instance method:        Map<String, dynamic> toJson() { ... }
      - A factory constructor:  factory YourClass.fromJson(Map<String, dynamic> json) { ... }
        Or, a static method:    static YourClass fromJson(Map<String, dynamic> json) { ... }
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
