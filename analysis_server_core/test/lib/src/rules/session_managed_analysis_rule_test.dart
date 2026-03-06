// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:analysis_server_core/src/models/session_data.dart';
import 'package:analysis_server_core/src/services/logger/session_logger.dart';
import 'package:analysis_server_core/src/services/session/session_data_fetch_result.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _FakeRuleSessionContext extends Fake implements RuleSessionContext {}

class _MockRuleVisitorRegistry extends Mock implements RuleVisitorRegistry {}

class _MockRuleContext extends Mock implements RuleContext {}

class _MockRuleContextUnit extends Mock implements RuleContextUnit {}

class _MockRuleContextFile extends Mock implements File {}

class _MockSessionDataFetchResult extends Mock
    implements SessionDataFetchResult {}

class _MockSessionDataManager extends Mock implements SessionDataManager {}

class _MockSessionData extends Mock implements SessionData {}

class _MockSessionLogger extends Mock implements SessionLogger {}

class _MockContextConfig extends Mock implements ContextConfig {}

class _MockUnsupportedContextConfig extends Mock implements ContextConfig {}

class _MockScanConfig extends Mock implements ScanConfig {}

class _TestSessionManagedAnalysisRuleImpl
    extends SessionManagedAnalysisRule<_MockContextConfig> {
  RuleContext? context;
  RuleVisitorRegistry? registry;
  RuleSessionContext<_MockContextConfig>? sessionContext;

  _TestSessionManagedAnalysisRuleImpl(super.metadata, super.sessionDataManager);

  @override
  DiagnosticCode get diagnosticCode =>
      const LintCode('sample_lint_code', 'Sample lint description');

  @override
  void registerSessionedNodeProcessors(
    RuleContext context,
    RuleVisitorRegistry registry,
    RuleSessionContext<_MockContextConfig> sessionContext,
  ) {
    // Capture the incoming params to verify
    // call to registerSessionedNodeProcessors.
    this.context = context;
    this.registry = registry;
    this.sessionContext = sessionContext;
  }
}

void main() {
  const aCompilationUnitPath = 'x/y/z/lib/a.dart';
  const ruleMetadata = RuleMetadata('name', 'description');

  late _MockRuleVisitorRegistry mockRuleVisitorRegistry;
  late _MockRuleContext mockRuleContext;

  late _MockRuleContextUnit mockRuleContextUnit;
  late _MockRuleContextFile mockRuleContextFile;

  late _MockSessionDataFetchResult mockSessionDataFetchResult;
  late _MockSessionDataManager mockSessionDataManager;
  late _MockSessionData mockSessionData;
  late _MockSessionLogger mockSessionLogger;
  late _MockContextConfig mockContextConfig;
  late _MockUnsupportedContextConfig mockUnsupportedContextConfig;
  late _MockScanConfig mockScanConfig;

  late _TestSessionManagedAnalysisRuleImpl sut;

  setUpAll(() {
    registerFallbackValue(_FakeRuleSessionContext());
  });

  setUp(() {
    mockRuleVisitorRegistry = _MockRuleVisitorRegistry();
    mockRuleContext = _MockRuleContext();
    mockRuleContextUnit = _MockRuleContextUnit();
    mockRuleContextFile = _MockRuleContextFile();
    mockSessionDataFetchResult = _MockSessionDataFetchResult();
    mockSessionDataManager = _MockSessionDataManager();
    mockSessionData = _MockSessionData();
    mockSessionLogger = _MockSessionLogger();
    mockContextConfig = _MockContextConfig();
    mockUnsupportedContextConfig = _MockUnsupportedContextConfig();
    mockScanConfig = _MockScanConfig();

    sut = _TestSessionManagedAnalysisRuleImpl(
      ruleMetadata,
      mockSessionDataManager,
    );

    when(
      () => mockSessionDataManager.getSessionDataFor(mockRuleContext),
    ).thenReturn(mockSessionDataFetchResult);
    when(
      () => mockSessionDataFetchResult.sessionData,
    ).thenReturn(mockSessionData);
    when(() => mockSessionData.logger).thenReturn(mockSessionLogger);
    when(() => mockSessionData.config).thenReturn(mockContextConfig);
    when(() => mockContextConfig.scanConfig).thenReturn(mockScanConfig);
    when(
      () => mockUnsupportedContextConfig.scanConfig,
    ).thenReturn(mockScanConfig);
    when(() => mockRuleContext.definingUnit).thenReturn(mockRuleContextUnit);
    when(() => mockRuleContextUnit.file).thenReturn(mockRuleContextFile);
    when(() => mockRuleContextFile.path).thenReturn(aCompilationUnitPath);

    when(() => mockSessionDataFetchResult.isNewlyCreated).thenReturn(false);
    when(() => mockRuleContext.isInLibDir).thenReturn(true);
    when(() => mockScanConfig.scanLibDir).thenReturn(true);
    when(() => mockRuleContext.isInTestDirectory).thenReturn(false);
    when(() => mockScanConfig.scanTestDir).thenReturn(false);
    when(
      () => mockSessionLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) {});
    when(
      () => mockSessionLogger.logWarning(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) {});
    when(
      () => mockSessionLogger.logError(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) {});
  });

  test(
    'Should log about newly created session and continue if everything is good',
    () {
      when(() => mockSessionDataFetchResult.isNewlyCreated).thenReturn(true);
      when(() => mockContextConfig.toMap()).thenReturn({});

      sut.registerNodeProcessors(mockRuleVisitorRegistry, mockRuleContext);

      verify(
        () => mockSessionLogger.logInfo(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
          extras: any(named: 'extras'),
        ),
      ).called(1);
      expect(sut.context, mockRuleContext);
      expect(sut.registry, mockRuleVisitorRegistry);
      expect(
        sut.sessionContext,
        isA<RuleSessionContext<_MockContextConfig>>()
            .having((p) => p.config, 'ContextConfig', mockContextConfig)
            .having((p) => p.logger, 'SessionLogger', mockSessionLogger),
      );
    },
  );

  test(
    'Should log and return immediately if config is not of supported type',
    () {
      when(
        () => mockSessionData.config,
      ).thenReturn(mockUnsupportedContextConfig);

      sut.registerNodeProcessors(mockRuleVisitorRegistry, mockRuleContext);

      verify(
        () => mockSessionLogger.logWarning(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
        ),
      ).called(1);
      expect(sut.context, null);
      expect(sut.registry, null);
      expect(sut.sessionContext, null);
    },
  );

  test(
    'Should log and return immediately if RuleContext.isInLibDir = true & scanConfig.ScanLibDir = false',
    () {
      when(() => mockRuleContext.isInLibDir).thenReturn(true);
      when(() => mockScanConfig.scanLibDir).thenReturn(false);

      sut.registerNodeProcessors(mockRuleVisitorRegistry, mockRuleContext);

      verify(
        () => mockSessionLogger.logInfo(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
          extras: any(named: 'extras'),
        ),
      ).called(1);
      expect(sut.context, null);
      expect(sut.registry, null);
      expect(sut.sessionContext, null);
    },
  );

  test(
    'Should log and return immediately if RuleContext.isInTestDirectory = true & scanConfig.scanTestDir = false',
    () {
      when(() => mockRuleContext.isInTestDirectory).thenReturn(true);
      when(() => mockScanConfig.scanTestDir).thenReturn(false);

      sut.registerNodeProcessors(mockRuleVisitorRegistry, mockRuleContext);

      verify(
        () => mockSessionLogger.logInfo(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
          extras: any(named: 'extras'),
        ),
      ).called(1);
      expect(sut.context, null);
      expect(sut.registry, null);
      expect(sut.sessionContext, null);
    },
  );
}
