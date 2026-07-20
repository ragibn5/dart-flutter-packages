import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:json_parser_linter/src/plugins/json_parser_linter_plugin.dart';
import 'package:json_parser_linter/src/rules/json_parser_requirement_rule/json_parser_requirement_rule.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeAnalysisRule extends Fake implements AnalysisRule {}

class _MockSessionDataManager extends Mock implements SessionDataManager {}

class _MockPluginRegistry extends Mock implements PluginRegistry {}

void main() {
  late _MockSessionDataManager mockSessionDataManager;
  late _MockPluginRegistry mockPluginRegistry;

  late JsonParserLinterPlugin sut;

  setUpAll(() {
    registerFallbackValue(_FakeAnalysisRule());
  });

  setUp(() {
    mockSessionDataManager = _MockSessionDataManager();
    mockPluginRegistry = _MockPluginRegistry();

    sut = JsonParserLinterPlugin(mockSessionDataManager);
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
