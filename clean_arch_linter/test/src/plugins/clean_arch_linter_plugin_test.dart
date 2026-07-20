import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/plugins/clean_arch_linter_plugin.dart';
import 'package:clean_arch_linter/src/rules/dependency_direction_rule/dependency_direction_rule.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeAnalysisRule extends Fake implements AnalysisRule {}

class _MockSessionDataManager extends Mock implements SessionDataManager {}

class _MockPluginRegistry extends Mock implements PluginRegistry {}

void main() {
  late _MockSessionDataManager mockSessionDataManager;
  late _MockPluginRegistry mockPluginRegistry;

  late CleanArchLinterPlugin sut;

  setUpAll(() {
    registerFallbackValue(_FakeAnalysisRule());
  });

  setUp(() {
    mockSessionDataManager = _MockSessionDataManager();
    mockPluginRegistry = _MockPluginRegistry();

    sut = CleanArchLinterPlugin(mockSessionDataManager);
  });

  test('Should register DependencyDirectionRule as a lint rule', () {
    sut.register(mockPluginRegistry);

    verify(
      () => mockPluginRegistry.registerLintRule(
        any(that: isA<DependencyDirectionRule>()),
      ),
    ).called(1);
  });
}
