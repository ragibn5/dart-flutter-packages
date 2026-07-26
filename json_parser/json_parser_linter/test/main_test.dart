import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:json_parser_linter/main.dart';
import 'package:json_parser_linter/src/rules/json_parser_requirement_rule/json_parser_requirement_rule.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeAnalysisRule extends Fake implements AnalysisRule {}

class _MockPluginRegistry extends Mock implements PluginRegistry {}

void main() {
  late _MockPluginRegistry mockPluginRegistry;

  setUpAll(() {
    registerFallbackValue(_FakeAnalysisRule());
  });

  setUp(() {
    mockPluginRegistry = _MockPluginRegistry();
  });

  test('Plugin name should be JsonParserLinterPlugin', () {
    expect(plugin.name, 'JsonParserLinterPlugin');
  });

  test('Should register JsonParserRequirementRule as a lint rule', () {
    plugin.register(mockPluginRegistry);

    verify(
      () => mockPluginRegistry.registerLintRule(
        any(that: isA<JsonParserRequirementRule>()),
      ),
    ).called(1);
  });
}
