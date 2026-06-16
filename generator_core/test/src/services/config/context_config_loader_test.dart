// ignore_for_file: lines_longer_than_80_chars

import 'package:build/build.dart';
import 'package:generator_core/src/models/context_config.dart';
import 'package:generator_core/src/services/config/context_config_loader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_config/package_config.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockBuildStep extends Mock implements BuildStep {}

class _MockPackageConfig extends Mock implements PackageConfig {}

class _MockPackage extends Mock implements Package {}

class _MockContextConfig extends Mock implements ContextConfig {}

class _TestContextConfigLoader extends ContextConfigLoader<_MockContextConfig> {
  BuildStep? buildStep;
  BuilderOptions? builderOptions;

  _TestContextConfigLoader(super.builderOptions);

  @override
  _MockContextConfig loadPluginConfig(
    BuildStep buildStep,
    BuilderOptions builderOptions,
  ) {
    this.buildStep = buildStep;
    this.builderOptions = builderOptions;
    return _MockContextConfig();
  }
}

void main() {
  const packageName = 'my_package';
  const packageRoot = 'x/y/z';
  const builderOptions = BuilderOptions({'key': 'value'});

  late _MockBuildStep mockBuildStep;
  late _MockPackageConfig mockPackageConfig;

  late _TestContextConfigLoader sut;

  setUp(() {
    mockBuildStep = _MockBuildStep();
    mockPackageConfig = _MockPackageConfig();

    sut = _TestContextConfigLoader(builderOptions);

    when(
      () => mockBuildStep.packageConfig,
    ).thenAnswer((_) async => mockPackageConfig);
    when(
      () => mockBuildStep.inputId,
    ).thenReturn(AssetId(packageName, 'lib/something.dart'));
  });

  test(
    'Should forward the buildStep and builderOptions correctly',
    () async {
      final mockPackage = _MockPackage();
      when(() => mockPackage.name).thenReturn(packageName);
      when(() => mockPackage.root).thenReturn(Uri.parse(packageRoot));
      when(() => mockPackageConfig.packages).thenReturn([mockPackage]);

      await sut.loadConfig(mockBuildStep);

      expect(sut.buildStep, mockBuildStep);
      expect(sut.builderOptions, builderOptions);
    },
  );
}
