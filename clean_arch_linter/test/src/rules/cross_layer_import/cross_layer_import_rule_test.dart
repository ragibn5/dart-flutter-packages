// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:clean_arch_linter/src/models/clean_arch_linter_config.dart';
import 'package:clean_arch_linter/src/models/domain_config.dart';
import 'package:clean_arch_linter/src/rules/cross_layer_import/cross_layer_import_rule.dart';
import 'package:clean_arch_linter/src/rules/cross_layer_import/cross_layer_import_visitor.dart';
import 'package:clean_arch_linter/src/services/domain_dir_path_resolver/domain_dir_path_resolver.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _FakeCrossLayerImportVisitor extends Fake
    implements CrossLayerImportVisitor {}

class _MockSessionDataManager extends Mock implements SessionDataManager {}

class _MockRuleContext extends Mock implements RuleContext {}

class _MockRuleContextUnit extends Mock implements RuleContextUnit {}

class _MockAnalyzerFile extends Mock implements AnalyzerFile {}

class _MockRuleVisitorRegistry extends Mock implements RuleVisitorRegistry {}

class _MockRuleSessionContext extends Mock
    implements RuleSessionContext<CleanArchLinterConfig> {}

class _MockCleanArchLinterConfig extends Mock
    implements CleanArchLinterConfig {}

class _MockDomainConfig extends Mock implements DomainConfig {}

class _MockSessionLogger extends Mock implements SessionLogger {}

class _MockDomainDirPathResolver extends Mock
    implements DomainDirPathResolver {}

class _MockWorkspacePackage extends Mock implements WorkspacePackage {}

class _MockFolder extends Mock implements Folder {}

void main() {
  const domainDirectoryNames = ['domain'];
  const projectRoot = '/Users/foo/project/';
  const domainDirPath = 'lib/features/auth/domain/';
  const pkgRelativeUnitPath =
      'lib/features/auth/domain/services/auth_data_service.dart';
  const domainUnitLocation = '/Users/foo/project/$pkgRelativeUnitPath';
  const nonDomainUnitLocation =
      '/Users/foo/project/lib/features/auth/data/sources/local_auth_data_source.dart';

  late _MockSessionDataManager mockSessionDataManager;
  late _MockRuleContext mockRuleContext;
  late _MockRuleContextUnit mockRuleContextUnit;
  late _MockAnalyzerFile mockContextUnitFile;
  late _MockRuleVisitorRegistry mockRuleVisitorRegistry;
  late _MockRuleSessionContext mockRuleSessionContext;
  late _MockCleanArchLinterConfig mockCleanArchLinterConfig;
  late _MockDomainConfig mockDomainConfig;
  late _MockSessionLogger mockSessionLogger;
  late _MockDomainDirPathResolver mockDomainDirPathResolver;
  late _MockWorkspacePackage mockWorkspacePackage;
  late _MockFolder mockFolder;

  late CrossLayerImportRule sut;

  setUpAll(() {
    registerFallbackValue(_FakeCrossLayerImportVisitor());
  });

  setUp(() {
    mockSessionDataManager = _MockSessionDataManager();
    mockRuleContext = _MockRuleContext();
    mockRuleContextUnit = _MockRuleContextUnit();
    mockContextUnitFile = _MockAnalyzerFile();
    mockRuleVisitorRegistry = _MockRuleVisitorRegistry();
    mockRuleSessionContext = _MockRuleSessionContext();
    mockCleanArchLinterConfig = _MockCleanArchLinterConfig();
    mockDomainConfig = _MockDomainConfig();
    mockSessionLogger = _MockSessionLogger();
    mockDomainDirPathResolver = _MockDomainDirPathResolver();
    mockWorkspacePackage = _MockWorkspacePackage();
    mockFolder = _MockFolder();

    sut = CrossLayerImportRule(
      mockSessionDataManager,
      domainDirPathResolver: mockDomainDirPathResolver,
    );

    when(() => mockRuleContext.definingUnit).thenReturn(mockRuleContextUnit);
    when(() => mockRuleContextUnit.file).thenReturn(mockContextUnitFile);
    when(() => mockContextUnitFile.path).thenReturn(domainUnitLocation);
    when(() => mockRuleContext.package).thenReturn(mockWorkspacePackage);
    when(() => mockWorkspacePackage.root).thenReturn(mockFolder);
    when(() => mockFolder.path).thenReturn(projectRoot);
    when(
      () => mockRuleSessionContext.config,
    ).thenReturn(mockCleanArchLinterConfig);
    when(
      () => mockCleanArchLinterConfig.domainConfig,
    ).thenReturn(mockDomainConfig);
    when(
      () => mockDomainConfig.domainDirNames,
    ).thenReturn(domainDirectoryNames);
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
      when(() => mockContextUnitFile.path).thenReturn(nonDomainUnitLocation);
      when(
        () => mockDomainDirPathResolver.findDomainDirPath(any(), any()),
      ).thenReturn(null);

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
      when(
        () => mockDomainDirPathResolver.findDomainDirPath(any(), any()),
      ).thenReturn(domainDirPath);

      sut.registerSessionedNodeProcessors(
        mockRuleContext,
        mockRuleVisitorRegistry,
        mockRuleSessionContext,
      );

      verify(
        () => mockRuleVisitorRegistry.addImportDirective(
          sut,
          any(
            that: isA<CrossLayerImportVisitor>()
                .having((p) => p.rule, 'rule', sut)
                .having(
                  (p) => p.domainUnitContext.unitPath,
                  'domainUnitContext.unitPath',
                  pkgRelativeUnitPath,
                )
                .having(
                  (p) => p.domainUnitContext.domainDirPath,
                  'domainUnitContext.domainDirPath',
                  domainDirPath,
                )
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
