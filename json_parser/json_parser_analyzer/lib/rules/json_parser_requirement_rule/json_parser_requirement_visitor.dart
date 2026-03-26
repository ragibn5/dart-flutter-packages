import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/models/json_parser_lint_config.dart';
import 'package:meta/meta.dart';

class JsonParserRequirementRuleVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final RuleSessionContext<JsonParserLintConfig> sessionContext;

  JsonParserRequirementRuleVisitor(
    AnalysisRule rule,
    RuleSessionContext<JsonParserLintConfig> sessionContext,
  ) : this._(rule, sessionContext);

  @visibleForTesting
  JsonParserRequirementRuleVisitor.test(
    AnalysisRule rule,
    RuleSessionContext<JsonParserLintConfig> sessionContext,
  ) : this._(rule, sessionContext);

  JsonParserRequirementRuleVisitor._(this.rule, this.sessionContext);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // TODO: implement visitClassDeclaration
    super.visitClassDeclaration(node);
  }
}
