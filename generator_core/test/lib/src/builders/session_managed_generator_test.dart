// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:generator_core/generator_core.dart';
import 'package:generator_core/src/builders/session_managed_generator.dart';
import 'package:generator_core/src/models/build_session_context.dart';
import 'package:generator_core/src/models/session_data.dart';
import 'package:generator_core/src/models/session_data_fetch_result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockSessionDataManager extends Mock implements SessionDataManager {}

class _MockBuildStep extends Mock implements BuildStep {}

class _MockSessionData extends Mock implements SessionData {}

class _MockSessionDataFetchResult extends Mock
    implements SessionDataFetchResult {}

class _MockSessionLogger extends Mock implements SessionLogger {}

class _MockContextConfig extends Mock implements ContextConfig {}

class _MockLibraryReader extends Mock implements LibraryReader {}

class _TestContextConfig extends ContextConfig {
  const _TestContextConfig({
    required super.packageInfo,
    required super.logConfig,
  });

  @override
  Map<String, dynamic> toMap() => {};
}

class _TestSessionManagedGenerator
    extends SessionManagedGenerator<_TestContextConfig> {
  BuildSessionContext<_TestContextConfig>? capturedSessionContext;
  String? generateResult;

  _TestSessionManagedGenerator(
    super.builderOptions,
    super.sessionDataManager, {
    this.generateResult,
  });

  @override
  Future<String?> generateWithSession(
    LibraryReader library,
    BuildStep buildStep,
    BuildSessionContext<_TestContextConfig> sessionContext,
  ) async {
    capturedSessionContext = sessionContext;
    return generateResult;
  }
}

void main() {
  const buildOptions = BuilderOptions({'key': 'value'});
  const testConfig = _TestContextConfig(
    packageInfo: PackageInfo(name: 'name', location: 'location'),
    logConfig: LogConfig(
      logDirectoryRelativePathFromProjectRoot: 'logs',
      enabled: true,
      allowInfoLog: true,
      allowWarningLog: true,
      allowErrorLog: true,
    ),
  );

  late _MockSessionDataManager mockSessionDataManager;
  late _MockBuildStep mockBuildStep;
  late _MockSessionData mockSessionData;
  late _MockSessionDataFetchResult mockFetchResult;
  late _MockSessionLogger mockSessionLogger;
  late _MockLibraryReader mockLibraryReader;
  late _TestSessionManagedGenerator sut;

  setUp(() {
    mockSessionDataManager = _MockSessionDataManager();
    mockBuildStep = _MockBuildStep();
    mockSessionData = _MockSessionData();
    mockFetchResult = _MockSessionDataFetchResult();
    mockSessionLogger = _MockSessionLogger();
    mockLibraryReader = _MockLibraryReader();

    sut = _TestSessionManagedGenerator(buildOptions, mockSessionDataManager);

    when(
      () =>
          mockSessionDataManager.getSessionDataFor(mockBuildStep, buildOptions),
    ).thenAnswer((_) async => mockFetchResult);
    when(() => mockFetchResult.sessionData).thenReturn(mockSessionData);
    when(() => mockSessionData.logger).thenReturn(mockSessionLogger);
    when(() => mockSessionData.config).thenReturn(testConfig);
    when(() => mockFetchResult.isNewlyCreated).thenReturn(false);
  });

  test('Should log session start info when session is newly created', () async {
    when(() => mockFetchResult.isNewlyCreated).thenReturn(true);
    when(
      () => mockSessionLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenReturn(null);

    await sut.generate(mockLibraryReader, mockBuildStep);

    verify(
      () => mockSessionLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).called(1);
  });

  test(
    'Should not log session start info when session is not newly created',
    () async {
      when(() => mockFetchResult.isNewlyCreated).thenReturn(false);

      await sut.generate(mockLibraryReader, mockBuildStep);

      verifyNever(
        () => mockSessionLogger.logInfo(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
          extras: any(named: 'extras'),
        ),
      );
    },
  );

  test(
    'Should call generateWithSession with correct session context and return its result when config type matches',
    () async {
      const expectedResult = 'generated_code';
      sut = _TestSessionManagedGenerator(
        buildOptions,
        mockSessionDataManager,
        generateResult: expectedResult,
      );

      final result = await sut.generate(mockLibraryReader, mockBuildStep);

      expect(sut.capturedSessionContext, isNotNull);
      expect(sut.capturedSessionContext!.config, testConfig);
      expect(sut.capturedSessionContext!.logger, mockSessionLogger);
      expect(result, expectedResult);
    },
  );

  test(
    'Should log warning and return null when config type does not match',
    () async {
      final mockContextConfig = _MockContextConfig();
      when(() => mockSessionData.config).thenReturn(mockContextConfig);
      when(
        () => mockSessionLogger.logWarning(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
        ),
      ).thenReturn(null);

      final result = await sut.generate(mockLibraryReader, mockBuildStep);

      verify(
        () => mockSessionLogger.logWarning(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
        ),
      ).called(1);
      expect(sut.capturedSessionContext, isNull);
      expect(result, isNull);
    },
  );
}
