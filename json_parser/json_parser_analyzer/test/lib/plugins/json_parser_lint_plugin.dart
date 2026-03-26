import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/src/plugins/json_parser_lint_plugin.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/json_parser_requirement_rule.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeAnalysisRule extends Fake implements AnalysisRule {}

class _MockSessionDataManager extends Mock implements SessionDataManager {}

class _MockPluginRegistry extends Mock implements PluginRegistry {}

void main() {
  late _MockSessionDataManager mockSessionDataManager;
  late _MockPluginRegistry mockPluginRegistry;

  late JsonParserLintPlugin sut;

  setUpAll(() {
    registerFallbackValue(_FakeAnalysisRule());
  });

  setUp(() {
    mockSessionDataManager = _MockSessionDataManager();
    mockPluginRegistry = _MockPluginRegistry();

    sut = JsonParserLintPlugin(mockSessionDataManager);
  });

  test('Should register JsonParserRequirementRule as a lint rule', () {
    sut.register(mockPluginRegistry);

    verify(
      () => mockPluginRegistry.registerLintRule(
        any(that: isA<JsonParserRequirementRule>()),
      ),
    ).called(1);
  });
}
