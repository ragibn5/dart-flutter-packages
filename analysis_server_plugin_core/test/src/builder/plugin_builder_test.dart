// ignore_for_file: cascade_invocations

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _TestConfig extends ContextConfig {
  const _TestConfig({required super.packageInfo, required super.logConfig});

  @override
  Map<String, dynamic> toMap() => {};
}

class _TestConfigLoader extends ContextConfigLoader<_TestConfig> {
  @override
  _TestConfig loadPluginConfig(RuleContext context, PackageInfo packageInfo) {
    return _TestConfig(
      packageInfo: packageInfo,
      logConfig: const LogConfig(
        logDirectoryRelativePathFromProjectRoot: 'logs/test',
      ),
    );
  }
}

class _TestRule extends SessionManagedAnalysisRule<_TestConfig> {
  _TestRule(SessionDataManager dm)
    : super(const RuleMetadata('test_rule', 'Test.'), dm);

  @override
  DiagnosticCode get diagnosticCode => const LintCode('test_rule', 'Test.');

  @override
  void registerSessionedNodeProcessors(
    RuleContext context,
    RuleVisitorRegistry registry,
    RuleSessionContext<_TestConfig> sessionContext,
  ) {}
}

class _MockSessionDataManager extends Mock implements SessionDataManager {}

class _MockPluginRegistry extends Mock implements PluginRegistry {}

void main() {
  late _TestConfigLoader testConfigLoader;
  late _MockPluginRegistry mockRegistry;

  setUpAll(() {
    registerFallbackValue(_TestRule(_MockSessionDataManager()));
  });

  setUp(() {
    testConfigLoader = _TestConfigLoader();
    mockRegistry = _MockPluginRegistry();
  });

  group('build() success', () {
    test('returns a Plugin with the correct name', () {
      final plugin = PluginBuilder<_TestConfig>(
        name: 'MyPlugin',
        configLoader: testConfigLoader,
      ).build();

      expect(plugin, isA<Plugin>());
      expect(plugin.name, 'MyPlugin');
    });

    test('succeeds with no registrations', () {
      final plugin = PluginBuilder<_TestConfig>(
        name: 'EmptyPlugin',
        configLoader: testConfigLoader,
      ).build();

      expect(plugin, isA<Plugin>());
      expect(plugin.name, 'EmptyPlugin');
    });
  });

  group('addLintRule()', () {
    test('registers one rule per factory', () {
      final plugin = PluginBuilder<_TestConfig>(
        name: 'Test',
        configLoader: testConfigLoader,
      ).addLintRule(_TestRule.new).addLintRule(_TestRule.new).build();

      plugin.register(mockRegistry);

      verify(() => mockRegistry.registerLintRule(any())).called(2);
    });
  });

  group('addWarningRule()', () {
    test('calls registerWarningRule for each factory', () {
      final plugin = PluginBuilder<_TestConfig>(
        name: 'Test',
        configLoader: testConfigLoader,
      ).addWarningRule(_TestRule.new).build();

      plugin.register(mockRegistry);

      verify(() => mockRegistry.registerWarningRule(any())).called(1);
    });
  });
}
