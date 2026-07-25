import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/main.dart';
import 'package:clean_arch_linter/src/rules/cross_layer_import/cross_layer_import_rule.dart';
import 'package:clean_arch_linter/src/rules/dart_sdk_import/dart_sdk_import_rule.dart';
import 'package:clean_arch_linter/src/rules/third_party_import/third_party_import_rule.dart';
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

  test('Should register all three lint rules', () {
    plugin.register(mockPluginRegistry);

    verify(
      () => mockPluginRegistry.registerLintRule(
        any(that: isA<DartSDKImportRule>()),
      ),
    ).called(1);
    verify(
      () => mockPluginRegistry.registerLintRule(
        any(that: isA<CrossLayerImportRule>()),
      ),
    ).called(1);
    verify(
      () => mockPluginRegistry.registerLintRule(
        any(that: isA<ThirdPartyImportRule>()),
      ),
    ).called(1);
  });
}
