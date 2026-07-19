// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/ddr_config.dart';
import 'package:clean_arch_lint/src/rules/dependency_direction_rule/dependency_direction_rule.dart';
import 'package:clean_arch_lint/src/rules/dependency_direction_rule/dependency_direction_rule_visitor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _FakeDependencyDirectionRuleVisitor extends Fake
    implements DependencyDirectionRuleVisitor {}

class _MockSessionDataManager extends Mock implements SessionDataManager {}

class _MockRuleContext extends Mock implements RuleContext {}

class _MockRuleContextUnit extends Mock implements RuleContextUnit {}

class _MockAnalyzerFile extends Mock implements AnalyzerFile {}

class _MockRuleVisitorRegistry extends Mock implements RuleVisitorRegistry {}

class _MockRuleSessionContext extends Mock
    implements RuleSessionContext<_MockCleanArchLintConfig> {}

class _MockCleanArchLintConfig extends Mock implements CleanArchLintConfig {}

class _MockDependencyDirectionRuleConfig extends Mock
    implements DependencyDirectionRuleConfig {}

class _MockSessionLogger extends Mock implements SessionLogger {}

void main() {
  const domainDirectoryNames = ['domain'];
  const contextUnitLocation = 'a/b/c/lib/x.dart';

  late _MockSessionDataManager mockSessionDataManager;
  late _MockRuleContext mockRuleContext;
  late _MockRuleContextUnit mockRuleContextUnit;
  late _MockAnalyzerFile mockContextUnitFile;
  late _MockRuleVisitorRegistry mockRuleVisitorRegistry;
  late _MockRuleSessionContext mockRuleSessionContext;
  late _MockCleanArchLintConfig mockCleanArchLintConfig;
  late _MockDependencyDirectionRuleConfig mockDDRConfig;
  late _MockSessionLogger mockSessionLogger;

  late DependencyDirectionRule sut;

  setUpAll(() {
    registerFallbackValue(_FakeDependencyDirectionRuleVisitor());
  });

  setUp(() {
    mockSessionDataManager = _MockSessionDataManager();
    mockRuleContext = _MockRuleContext();
    mockRuleContextUnit = _MockRuleContextUnit();
    mockContextUnitFile = _MockAnalyzerFile();
    mockRuleVisitorRegistry = _MockRuleVisitorRegistry();
    mockRuleSessionContext = _MockRuleSessionContext();
    mockCleanArchLintConfig = _MockCleanArchLintConfig();
    mockDDRConfig = _MockDependencyDirectionRuleConfig();
    mockSessionLogger = _MockSessionLogger();

    sut = DependencyDirectionRule(mockSessionDataManager);

    when(() => mockRuleContext.definingUnit).thenReturn(mockRuleContextUnit);
    when(() => mockRuleContextUnit.file).thenReturn(mockContextUnitFile);
    when(() => mockContextUnitFile.path).thenReturn(contextUnitLocation);
    when(
      () => mockRuleSessionContext.config,
    ).thenReturn(mockCleanArchLintConfig);
    when(() => mockCleanArchLintConfig.ddrConfig).thenReturn(mockDDRConfig);
    when(() => mockDDRConfig.domainDirNames).thenReturn(domainDirectoryNames);
    when(() => mockRuleSessionContext.logger).thenReturn(mockSessionLogger);
    when(
      () => mockSessionLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) {});
  });

  test(
    'If source path does not contain domain directory name, we do not register any visitor',
    () {
      when(() => mockContextUnitFile.path).thenReturn(
        'a/b/c/lib/features/auth/data/sources/local_auth_data_source.dart',
      );

      sut.registerSessionedNodeProcessors(
        mockRuleContext,
        mockRuleVisitorRegistry,
        mockRuleSessionContext,
      );

      verify(
        () => mockSessionLogger.logInfo(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
        ),
      ).called(1);
      verifyNever(() => mockRuleVisitorRegistry.addImportDirective(sut, any()));
    },
  );

  test(
    'If source path contains domain directory name, we register the directive visitor',
    () {
      when(() => mockContextUnitFile.path).thenReturn(
        'a/b/c/lib/features/auth/domain/services/auth_data_service.dart',
      );

      sut.registerSessionedNodeProcessors(
        mockRuleContext,
        mockRuleVisitorRegistry,
        mockRuleSessionContext,
      );

      verify(
        () => mockSessionLogger.logInfo(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
        ),
      ).called(1);
      verify(
        () => mockRuleVisitorRegistry.addImportDirective(
          sut,
          any(
            that: isA<DependencyDirectionRuleVisitor>()
                .having((p) => p.rule, 'rule', sut)
                .having(
                  (p) => p.sessionContext,
                  'sessionContext',
                  mockRuleSessionContext,
                ),
          ),
        ),
      ).called(1);
    },
  );
}
