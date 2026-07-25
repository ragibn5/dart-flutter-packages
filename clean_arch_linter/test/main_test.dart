import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/main.dart';
import 'package:clean_arch_linter/src/rules/dependency_direction_rule/dependency_direction_rule.dart';
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

  test('Plugin name should be `CleanArchLinterPlugin`', () {
    expect(plugin.name, 'CleanArchLinterPlugin');
  });

  test('Should register DependencyDirectionRule as a lint rule', () {
    plugin.register(mockPluginRegistry);

    verify(
      () => mockPluginRegistry.registerLintRule(
        any(that: isA<DependencyDirectionRule>()),
      ),
    ).called(1);
  });
}
