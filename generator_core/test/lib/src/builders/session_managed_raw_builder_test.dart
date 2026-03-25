// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:build/build.dart';
import 'package:generator_core/src/builders/session_managed_raw_builder.dart';
import 'package:generator_core/src/models/build_session_context.dart';
import 'package:generator_core/src/models/context_config.dart';
import 'package:generator_core/src/models/log_config.dart';
import 'package:generator_core/src/models/package_info.dart';
import 'package:generator_core/src/models/session_data.dart';
import 'package:generator_core/src/models/session_data_fetch_result.dart';
import 'package:generator_core/src/services/logger/session_logger.dart';
import 'package:generator_core/src/services/session/session_data_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockSessionDataManager extends Mock implements SessionDataManager {}

class _MockBuildStep extends Mock implements BuildStep {}

class _MockSessionData extends Mock implements SessionData {}

class _MockSessionDataFetchResult extends Mock
    implements SessionDataFetchResult {}

class _MockSessionLogger extends Mock implements SessionLogger {}

class _MockContextConfig extends Mock implements ContextConfig {}

class _TestContextConfig extends ContextConfig {
  const _TestContextConfig({
    required super.packageInfo,
    required super.logConfig,
  });

  @override
  Map<String, dynamic> toMap() => {};
}

class _TestSessionManagedRawBuilder
    extends SessionManagedRawBuilder<_TestContextConfig> {
  BuildSessionContext<_TestContextConfig>? capturedSessionContext;

  _TestSessionManagedRawBuilder(super.sessionDataManager);

  @override
  Map<String, List<String>> get buildExtensions => {};

  @override
  Future<void> buildWithSession(
    BuildStep buildStep,
    BuildSessionContext<_TestContextConfig> sessionContext,
  ) async {
    capturedSessionContext = sessionContext;
  }
}

void main() {
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
  late _TestSessionManagedRawBuilder sut;

  setUp(() {
    mockSessionDataManager = _MockSessionDataManager();
    mockBuildStep = _MockBuildStep();
    mockSessionData = _MockSessionData();
    mockFetchResult = _MockSessionDataFetchResult();
    mockSessionLogger = _MockSessionLogger();

    sut = _TestSessionManagedRawBuilder(mockSessionDataManager);

    when(
      () => mockSessionDataManager.getSessionDataFor(mockBuildStep),
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

    await sut.build(mockBuildStep);

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
      await sut.build(mockBuildStep);

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
    'Should call buildWithSession with correct session context when config type matches',
    () async {
      await sut.build(mockBuildStep);

      expect(sut.capturedSessionContext, isNotNull);
      expect(sut.capturedSessionContext!.config, testConfig);
      expect(sut.capturedSessionContext!.logger, mockSessionLogger);
    },
  );

  test(
    'Should log warning and not call buildWithSession when config type does not match',
    () async {
      when(() => mockSessionData.config).thenReturn(_MockContextConfig());
      when(
        () => mockSessionLogger.logWarning(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
        ),
      ).thenReturn(null);

      await sut.build(mockBuildStep);

      verify(
        () => mockSessionLogger.logWarning(
          tag: any(named: 'tag'),
          message: any(named: 'message'),
        ),
      ).called(1);
      expect(sut.capturedSessionContext, isNull);
    },
  );
}