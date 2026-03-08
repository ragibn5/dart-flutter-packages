// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/ddr_config.dart';
import 'package:clean_arch_lint/src/rules/dependency_direction_rule.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class FakeDependencyDirectionRuleVisitor extends Fake
    implements DependencyDirectionRuleVisitor {}

class MockSessionDataManager extends Mock implements SessionDataManager {}

class MockRuleContext extends Mock implements RuleContext {}

class MockRuleContextUnit extends Mock implements RuleContextUnit {}

class MockAnalyzerFile extends Mock implements AnalyzerFile {}

class MockRuleVisitorRegistry extends Mock implements RuleVisitorRegistry {}

class MockRuleSessionContext extends Mock
    implements RuleSessionContext<MockCleanArchLintConfig> {}

class MockCleanArchLintConfig extends Mock implements CleanArchLintConfig {}

class MockDependencyDirectionRuleConfig extends Mock
    implements DependencyDirectionRuleConfig {}

class MockSessionLogger extends Mock implements SessionLogger {}

void main() {
  const domainDirectoryName = 'domain';
  const contextUnitLocation = 'a/b/c/lib/x.dart';

  late MockSessionDataManager mockSessionDataManager;
  late MockRuleContext mockRuleContext;
  late MockRuleContextUnit mockRuleContextUnit;
  late MockAnalyzerFile mockContextUnitFile;
  late MockRuleVisitorRegistry mockRuleVisitorRegistry;
  late MockRuleSessionContext mockRuleSessionContext;
  late MockCleanArchLintConfig mockCleanArchLintConfig;
  late MockDependencyDirectionRuleConfig mockDDRConfig;
  late MockSessionLogger mockSessionLogger;

  late DependencyDirectionRule sut;

  setUpAll(() {
    registerFallbackValue(FakeDependencyDirectionRuleVisitor());
  });

  setUp(() {
    mockSessionDataManager = MockSessionDataManager();
    mockRuleContext = MockRuleContext();
    mockRuleContextUnit = MockRuleContextUnit();
    mockContextUnitFile = MockAnalyzerFile();
    mockRuleVisitorRegistry = MockRuleVisitorRegistry();
    mockRuleSessionContext = MockRuleSessionContext();
    mockCleanArchLintConfig = MockCleanArchLintConfig();
    mockDDRConfig = MockDependencyDirectionRuleConfig();
    mockSessionLogger = MockSessionLogger();

    sut = DependencyDirectionRule(mockSessionDataManager);

    when(() => mockRuleContext.definingUnit).thenReturn(mockRuleContextUnit);
    when(() => mockRuleContextUnit.file).thenReturn(mockContextUnitFile);
    when(() => mockContextUnitFile.path).thenReturn(contextUnitLocation);
    when(
      () => mockRuleSessionContext.config,
    ).thenReturn(mockCleanArchLintConfig);
    when(() => mockCleanArchLintConfig.ddrConfig).thenReturn(mockDDRConfig);
    when(() => mockDDRConfig.domainDirName).thenReturn(domainDirectoryName);
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
