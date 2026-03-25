// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:generator_core/src/builders/session_managed_generator_for_annotation.dart';
import 'package:generator_core/src/models/build_session_context.dart';
import 'package:generator_core/src/models/context_config.dart';
import 'package:generator_core/src/models/log_config.dart';
import 'package:generator_core/src/models/package_info.dart';
import 'package:generator_core/src/models/session_data.dart';
import 'package:generator_core/src/models/session_data_fetch_result.dart';
import 'package:generator_core/src/services/logger/session_logger.dart';
import 'package:generator_core/src/services/session/session_data_manager.dart';
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

class _MockElement extends Mock implements Element {}

class _MockElementDirective extends Mock implements ElementDirective {}

class _MockConstantReader extends Mock implements ConstantReader {}

class _TestContextConfig extends ContextConfig {
  const _TestContextConfig({
    required super.packageInfo,
    required super.logConfig,
  });

  @override
  Map<String, dynamic> toMap() => {};
}

class _TestAnnotation {}

class _TestSessionManagedGeneratorForAnnotation
    extends
        SessionManagedGeneratorForAnnotation<
          _TestAnnotation,
          _TestContextConfig
        > {
  BuildSessionContext<_TestContextConfig>? capturedSessionContext;
  String generateResult;

  _TestSessionManagedGeneratorForAnnotation(
    super.sessionDataManager, {
    this.generateResult = '',
  });

  @override
  FutureOr<String> generateWithSession(
    LibraryReader library,
    BuildStep buildStep,
    BuildSessionContext<_TestContextConfig> sessionContext,
  ) {
    capturedSessionContext = sessionContext;
    return generateResult;
  }

  @override
  FutureOr<dynamic> generateForAnnotatedElementWithSession(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
    BuildSessionContext<_TestContextConfig> sessionContext,
  ) {
    capturedSessionContext = sessionContext;
    return 'element_result';
  }

  @override
  FutureOr<dynamic> generateForAnnotatedDirectiveWithSession(
    ElementDirective directive,
    ConstantReader annotation,
    BuildStep buildStep,
    BuildSessionContext<_TestContextConfig> sessionContext,
  ) {
    capturedSessionContext = sessionContext;
    return 'directive_result';
  }
}

void main() {
  const testConfig = _TestContextConfig(
    packageInfo: PackageInfo(name: 'name'),
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
  late _MockElement mockElement;
  late _MockElementDirective mockElementDirective;
  late _MockConstantReader mockConstantReader;

  late _TestSessionManagedGeneratorForAnnotation sut;

  setUp(() {
    mockSessionDataManager = _MockSessionDataManager();
    mockBuildStep = _MockBuildStep();
    mockSessionData = _MockSessionData();
    mockFetchResult = _MockSessionDataFetchResult();
    mockSessionLogger = _MockSessionLogger();
    mockLibraryReader = _MockLibraryReader();
    mockElement = _MockElement();
    mockElementDirective = _MockElementDirective();
    mockConstantReader = _MockConstantReader();

    sut = _TestSessionManagedGeneratorForAnnotation(mockSessionDataManager);

    when(
      () => mockSessionDataManager.getSessionDataFor(mockBuildStep),
    ).thenAnswer((_) async => mockFetchResult);
    when(() => mockFetchResult.sessionData).thenReturn(mockSessionData);
    when(() => mockSessionData.logger).thenReturn(mockSessionLogger);
    when(() => mockSessionData.config).thenReturn(testConfig);
    when(() => mockFetchResult.isNewlyCreated).thenReturn(false);
  });

  group('_resolveSessionContext (shared behavior across all entry points)', () {
    test(
      'Should log session start info when session is newly created',
      () async {
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
      },
    );

    test(
      'Should not log session start info when session is not newly created',
      () async {
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
  });

  group('generate', () {
    test(
      'Should call generateWithSession with correct session context and return its result',
      () async {
        sut = _TestSessionManagedGeneratorForAnnotation(
          mockSessionDataManager,
          generateResult: 'generated_code',
        );

        final result = await sut.generate(mockLibraryReader, mockBuildStep);

        expect(sut.capturedSessionContext, isNotNull);
        expect(sut.capturedSessionContext!.config, testConfig);
        expect(sut.capturedSessionContext!.logger, mockSessionLogger);
        expect(result, 'generated_code');
      },
    );

    test(
      'Should log warning and return empty string when config type does not match',
      () async {
        when(() => mockSessionData.config).thenReturn(_MockContextConfig());
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
        expect(result, '');
      },
    );
  });

  group('generateForAnnotatedElement', () {
    test(
      'Should call generateForAnnotatedElementWithSession with correct session context and return its result',
      () async {
        final result = await sut.generateForAnnotatedElement(
          mockElement,
          mockConstantReader,
          mockBuildStep,
        );

        expect(sut.capturedSessionContext, isNotNull);
        expect(sut.capturedSessionContext!.config, testConfig);
        expect(sut.capturedSessionContext!.logger, mockSessionLogger);
        expect(result, 'element_result');
      },
    );

    test(
      'Should log warning and return null when config type does not match',
      () async {
        when(() => mockSessionData.config).thenReturn(_MockContextConfig());
        when(
          () => mockSessionLogger.logWarning(
            tag: any(named: 'tag'),
            message: any(named: 'message'),
          ),
        ).thenReturn(null);

        final result = await sut.generateForAnnotatedElement(
          mockElement,
          mockConstantReader,
          mockBuildStep,
        );

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
  });

  group('generateForAnnotatedDirective', () {
    test(
      'Should call generateForAnnotatedDirectiveWithSession with correct session context and return its result',
      () async {
        final result = await sut.generateForAnnotatedDirective(
          mockElementDirective,
          mockConstantReader,
          mockBuildStep,
        );

        expect(sut.capturedSessionContext, isNotNull);
        expect(sut.capturedSessionContext!.config, testConfig);
        expect(sut.capturedSessionContext!.logger, mockSessionLogger);
        expect(result, 'directive_result');
      },
    );

    test(
      'Should log warning and return null when config type does not match',
      () async {
        when(() => mockSessionData.config).thenReturn(_MockContextConfig());
        when(
          () => mockSessionLogger.logWarning(
            tag: any(named: 'tag'),
            message: any(named: 'message'),
          ),
        ).thenReturn(null);

        final result = await sut.generateForAnnotatedDirective(
          mockElementDirective,
          mockConstantReader,
          mockBuildStep,
        );

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
  });
}
