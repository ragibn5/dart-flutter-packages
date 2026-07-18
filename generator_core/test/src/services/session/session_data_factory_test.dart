// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'dart:io';

import 'package:build/build.dart';
import 'package:loghub/loghub.dart';
import 'package:generator_core/src/models/context_config.dart';
import 'package:generator_core/src/models/log_config.dart';
import 'package:generator_core/src/services/config/context_config_loader.dart';
import 'package:generator_core/src/services/logger/session_logger.dart';
import 'package:generator_core/src/services/session/session_data_factory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockContextConfigLoader extends Mock implements ContextConfigLoader {}

class _MockBuildStep extends Mock implements BuildStep {}

class _TestContextConfig extends ContextConfig {
  const _TestContextConfig({required super.logConfig});

  @override
  Map<String, dynamic> toMap() => {};
}

void main() {
  const logDirRelative = 'logDirectoryRelativePathFromCurrentDir';

  const config = _TestContextConfig(
    logConfig: LogConfig(
      logDirectoryRelativePathFromCurrentDir: logDirRelative,
      enabled: true,
      allowInfoLog: true,
      allowWarningLog: true,
      allowErrorLog: true,
    ),
  );

  late _MockContextConfigLoader mockContextConfigLoader;
  late _MockBuildStep mockBuildStep;

  late Directory fakeCurrentDirectory;
  late SessionDataFactory sut;

  setUp(() {
    mockContextConfigLoader = _MockContextConfigLoader();
    mockBuildStep = _MockBuildStep();

    fakeCurrentDirectory = Directory('/fake/root');

    sut = SessionDataFactoryImpl.test(
      fakeCurrentDirectory,
      mockContextConfigLoader,
    );

    when(
      () => mockContextConfigLoader.loadConfig(mockBuildStep),
    ).thenAnswer((_) async => config);
  });

  test('SessionLogger should reflect config flags correctly', () async {
    final logger = (await sut.createSessionData(mockBuildStep)).logger;

    expect(
      logger,
      isA<SessionLogger>()
          .having((p) => p.enabled, 'enabled', config.logConfig.enabled)
          .having(
            (p) => p.allowedLevels,
            'allowedLevels',
            containsAll({
              if (config.logConfig.allowInfoLog) SessionLogLevel.INFO,
              if (config.logConfig.allowWarningLog) SessionLogLevel.WARNING,
              if (config.logConfig.allowErrorLog) SessionLogLevel.ERROR,
            }),
          ),
    );
  });

  test(
    'ContextConfig should be the same instance returned by loader',
    () async {
      final localConfig = (await sut.createSessionData(mockBuildStep)).config;
      expect(config, same(localConfig));
    },
  );

  test(
    'FileLogger should resolve log directory relative to injected current directory',
    () async {
      final sessionData = await sut.createSessionData(mockBuildStep);

      final logger = sessionData.logger as SessionLoggerImpl;

      final fileLogger = logger.getLogger('file-logger') as FileLogger?;
      if (fileLogger == null) {
        fail('FileLogger not found with given key');
      }

      final expectedPath = path.join(
        fakeCurrentDirectory.absolute.path,
        logDirRelative,
      );

      expect(fileLogger.logDirectory.path, equals(expectedPath));
    },
  );
}
