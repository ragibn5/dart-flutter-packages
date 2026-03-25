// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:build/build.dart';
import 'package:generator_core/src/models/context_config.dart';
import 'package:generator_core/src/models/log_config.dart';
import 'package:generator_core/src/models/package_info.dart';
import 'package:generator_core/src/services/config/context_config_loader.dart';
import 'package:generator_core/src/services/logger/session_logger.dart';
import 'package:generator_core/src/services/session/session_data_factory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockContextConfigLoader extends Mock implements ContextConfigLoader {}

class _MockBuildStep extends Mock implements BuildStep {}

class _TestContextConfig extends ContextConfig {
  const _TestContextConfig({
    required super.packageInfo,
    required super.logConfig,
  });

  @override
  Map<String, dynamic> toMap() => {};
}

void main() {
  const config = _TestContextConfig(
    packageInfo: PackageInfo(name: 'name', location: 'location'),
    logConfig: LogConfig(
      logDirectoryRelativePathFromProjectRoot:
          'logDirectoryRelativePathFromProjectRoot',
      enabled: true,
      allowInfoLog: true,
      allowWarningLog: true,
      allowErrorLog: true,
    ),
  );

  late _MockContextConfigLoader mockContextConfigLoader;
  late _MockBuildStep mockBuildStep;

  late SessionDataFactory sut;

  setUp(() {
    mockContextConfigLoader = _MockContextConfigLoader();
    mockBuildStep = _MockBuildStep();

    sut = SessionDataFactoryImpl(mockContextConfigLoader);

    when(
      () => mockContextConfigLoader.loadConfig(mockBuildStep),
    ).thenAnswer((_) async => config);
  });

  test(
    'Returned SessionData.SessionLogger should map to appropriate config',
    () async {
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
    },
  );

  test(
    'Returned SessionData.ContextConfig should be the same returned by ContextConfigLoader',
    () async {
      final localConfig = (await sut.createSessionData(mockBuildStep)).config;
      expect(config, localConfig);
    },
  );
}
