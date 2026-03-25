// ignore_for_file: lines_longer_than_80_chars

import 'package:build/build.dart';
import 'package:generator_core/generator_core.dart';
import 'package:json_parser_generator/src/models/json_parser_generator_context_config.dart';
import 'package:json_parser_generator/src/services/config/json_parser_generator_config_loader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

class _MockBuildStep extends Mock implements BuildStep {}

class _MockPackageConfig extends Mock implements PackageConfig {}

class _MockPackage extends Mock implements Package {}

void main() {
  const packageName = 'my_package';
  const packageRoot = 'x/y/z';

  final defaultLogDir = path.joinAll([
    'logs',
    'generators',
    'json_parser_generator',
  ]);

  late _MockBuildStep mockBuildStep;
  late _MockPackageConfig mockPackageConfig;
  late _MockPackage mockPackage;

  setUp(() {
    mockBuildStep = _MockBuildStep();
    mockPackageConfig = _MockPackageConfig();
    mockPackage = _MockPackage();

    when(
      () => mockBuildStep.packageConfig,
    ).thenAnswer((_) async => mockPackageConfig);
    when(
      () => mockBuildStep.inputId,
    ).thenReturn(AssetId(packageName, 'lib/something.dart'));
    when(() => mockPackage.name).thenReturn(packageName);
    when(() => mockPackage.root).thenReturn(Uri.parse(packageRoot));
    when(() => mockPackageConfig.packages).thenReturn([mockPackage]);
  });

  test(
    'Should return config with default LogConfig when no log_config is provided',
    () async {
      final sut = JsonParserGeneratorConfigLoader(BuilderOptions.empty);

      final result = await sut.loadConfig(mockBuildStep);

      expect(
        result,
        isA<JsonParserGeneratorContextConfig>()
            .having((c) => c.packageInfo.name, 'packageInfo.name', packageName)
            .having(
              (c) => c.packageInfo.location,
              'packageInfo.location',
              packageRoot,
            )
            .having(
              (c) => c.logConfig.logDirectoryRelativePathFromProjectRoot,
              'logConfig.logDir',
              defaultLogDir,
            )
            .having((c) => c.logConfig.enabled, 'logConfig.enabled', false)
            .having(
              (c) => c.logConfig.allowInfoLog,
              'logConfig.allowInfoLog',
              false,
            )
            .having(
              (c) => c.logConfig.allowWarningLog,
              'logConfig.allowWarningLog',
              false,
            )
            .having(
              (c) => c.logConfig.allowErrorLog,
              'logConfig.allowErrorLog',
              true,
            ),
      );
    },
  );

  test(
    'Should return config with default LogConfig when log_config is not a Map',
    () async {
      final sut = JsonParserGeneratorConfigLoader(
        const BuilderOptions({'log_config': 'invalid'}),
      );

      final result = await sut.loadConfig(mockBuildStep);

      expect(
        result,
        isA<JsonParserGeneratorContextConfig>()
            .having(
              (c) => c.logConfig.logDirectoryRelativePathFromProjectRoot,
              'logConfig.logDir',
              defaultLogDir,
            )
            .having((c) => c.logConfig.enabled, 'logConfig.enabled', false)
            .having(
              (c) => c.logConfig.allowInfoLog,
              'logConfig.allowInfoLog',
              false,
            )
            .having(
              (c) => c.logConfig.allowWarningLog,
              'logConfig.allowWarningLog',
              false,
            )
            .having(
              (c) => c.logConfig.allowErrorLog,
              'logConfig.allowErrorLog',
              true,
            ),
      );
    },
  );

  test(
    'Should return config with provided LogConfig values when log_config is valid',
    () async {
      final sut = JsonParserGeneratorConfigLoader(
        const BuilderOptions({
          'log_config': {
            'enabled': true,
            'allow_info': true,
            'allow_warning': true,
            'allow_error': false,
            'log_dir_relative_path': 'custom/log/dir',
          },
        }),
      );

      final result = await sut.loadConfig(mockBuildStep);

      expect(
        result,
        isA<JsonParserGeneratorContextConfig>()
            .having((c) => c.logConfig.enabled, 'logConfig.enabled', true)
            .having(
              (c) => c.logConfig.allowInfoLog,
              'logConfig.allowInfoLog',
              true,
            )
            .having(
              (c) => c.logConfig.allowWarningLog,
              'logConfig.allowWarningLog',
              true,
            )
            .having(
              (c) => c.logConfig.allowErrorLog,
              'logConfig.allowErrorLog',
              false,
            )
            .having(
              (c) => c.logConfig.logDirectoryRelativePathFromProjectRoot,
              'logConfig.logDir',
              'custom/log/dir',
            ),
      );
    },
  );

  test(
    'Should fall back to production defaults for missing keys within log_config',
    () async {
      final sut = JsonParserGeneratorConfigLoader(
        const BuilderOptions({'log_config': <String, dynamic>{}}),
      );

      final result = await sut.loadConfig(mockBuildStep);

      expect(
        result,
        isA<JsonParserGeneratorContextConfig>()
            .having((c) => c.logConfig.enabled, 'logConfig.enabled', true)
            .having(
              (c) => c.logConfig.allowInfoLog,
              'logConfig.allowInfoLog',
              true,
            )
            .having(
              (c) => c.logConfig.allowWarningLog,
              'logConfig.allowWarningLog',
              true,
            )
            .having(
              (c) => c.logConfig.allowErrorLog,
              'logConfig.allowErrorLog',
              true,
            )
            .having(
              (c) => c.logConfig.logDirectoryRelativePathFromProjectRoot,
              'logConfig.logDir',
              defaultLogDir,
            ),
      );
    },
  );
}
