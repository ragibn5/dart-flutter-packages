// ignore_for_file: lines_longer_than_80_chars

import 'dart:io' as dart_io;

import 'package:analysis_server_plugin_core/src/models/context_config.dart';
import 'package:analysis_server_plugin_core/src/models/package_info.dart';
import 'package:analysis_server_plugin_core/src/services/config/config_source_provider.dart';
import 'package:analysis_server_plugin_core/src/services/config/context_config_loader.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/file_system/file_system.dart' as analyzer_io;
import 'package:analyzer/workspace/workspace.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _FakePackageInfo extends Fake implements PackageInfo {}

class _MockRuleContext extends Mock implements RuleContext {}

class _MockWorkspacePackage extends Mock implements WorkspacePackage {}

class _MockRuleContextUnit extends Mock implements RuleContextUnit {}

class _MockDartFile extends Mock implements dart_io.File {}

class _MocAnalyzerFile extends Mock implements analyzer_io.File {}

class _MockAnalyzerFolder extends Mock implements analyzer_io.Folder {}

class _MockContextConfig extends Mock implements ContextConfig {}

class _MockConfigSourceProvider extends Mock implements ConfigSourceProvider {}

class _TestContextConfigLoader extends ContextConfigLoader<_MockContextConfig> {
  RuleContext? context;
  PackageInfo? packageInfo;

  // ignore: use_super_parameters
  _TestContextConfigLoader(ConfigSourceProvider sourceProvider)
    : super.test(sourceProvider);

  @override
  _MockContextConfig loadPluginConfig(
    RuleContext context,
    PackageInfo packageInfo,
  ) {
    this.context = context;
    this.packageInfo = packageInfo;
    return _MockContextConfig();
  }
}

void main() {
  // Real package info = (name = package-name, location = package-root)
  // Fallback/Default package info = (name = null, location = compilation-unit-location)

  const packageRoot = 'x/y/z';
  const compilationUnitParent = 'x/y/z/lib';

  late _MockRuleContext mockRuleContext;
  late _MockWorkspacePackage mockWorkspacePackage;
  late _MockRuleContextUnit mockRuleContextUnit;
  late _MockDartFile mockConfigFile;
  late _MocAnalyzerFile mockUnitFile;
  late _MockAnalyzerFolder mockUnitParentFolder;
  late _MockAnalyzerFolder mockPackageRootFolder;
  late _MockConfigSourceProvider mockConfigSourceProvider;

  late _TestContextConfigLoader sut;

  setUpAll(() {
    registerFallbackValue(_FakePackageInfo());
  });

  setUp(() {
    mockRuleContext = _MockRuleContext();
    mockWorkspacePackage = _MockWorkspacePackage();
    mockRuleContextUnit = _MockRuleContextUnit();
    mockConfigFile = _MockDartFile();
    mockUnitFile = _MocAnalyzerFile();
    mockUnitParentFolder = _MockAnalyzerFolder();
    mockPackageRootFolder = _MockAnalyzerFolder();
    mockConfigSourceProvider = _MockConfigSourceProvider();

    sut = _TestContextConfigLoader(mockConfigSourceProvider);

    when(() => mockRuleContext.package).thenReturn(mockWorkspacePackage);
    when(() => mockWorkspacePackage.root).thenReturn(mockPackageRootFolder);
    when(() => mockPackageRootFolder.path).thenReturn(packageRoot);
    when(() => mockRuleContext.definingUnit).thenReturn(mockRuleContextUnit);
    when(() => mockRuleContextUnit.file).thenReturn(mockUnitFile);
    when(() => mockConfigFile.existsSync()).thenReturn(true);
    when(() => mockUnitFile.parent).thenReturn(mockUnitParentFolder);
    when(() => mockUnitParentFolder.path).thenReturn(compilationUnitParent);
  });

  test('Should return default package-info if package is null', () {
    when(() => mockRuleContext.package).thenReturn(null);

    sut.loadConfig(mockRuleContext);

    final context = sut.context;
    final packageInfo = sut.packageInfo;
    expect(context, mockRuleContext);
    expect(
      packageInfo,
      isA<PackageInfo>()
          .having((p) => p.name, 'name', isNull)
          .having((p) => p.location, 'location', compilationUnitParent),
    );
  });

  test(
    'Should return default package-info if config source does not exist',
    () {
      when(mockConfigFile.existsSync).thenReturn(false);
      when(
        () => mockConfigSourceProvider.getConfigSource(
          mockWorkspacePackage,
          any(),
        ),
      ).thenReturn(mockConfigFile);

      sut.loadConfig(mockRuleContext);

      final context = sut.context;
      final packageInfo = sut.packageInfo;
      expect(context, mockRuleContext);
      expect(
        packageInfo,
        isA<PackageInfo>()
            .having((p) => p.name, 'name', isNull)
            .having((p) => p.location, 'location', compilationUnitParent),
      );
    },
  );

  test(
    'Should return default package-info if config source returns empty data',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('');
      when(
        () => mockConfigSourceProvider.getConfigSource(
          mockWorkspacePackage,
          any(),
        ),
      ).thenReturn(mockConfigFile);

      sut.loadConfig(mockRuleContext);

      final context = sut.context;
      final packageInfo = sut.packageInfo;
      expect(context, mockRuleContext);
      expect(
        packageInfo,
        isA<PackageInfo>()
            .having((p) => p.name, 'name', isNull)
            .having((p) => p.location, 'location', compilationUnitParent),
      );
    },
  );

  test(
    'Should return default package-info if config source returns unsupported format',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('Hello-World');
      when(
        () => mockConfigSourceProvider.getConfigSource(
          mockWorkspacePackage,
          any(),
        ),
      ).thenReturn(mockConfigFile);

      sut.loadConfig(mockRuleContext);

      final context = sut.context;
      final packageInfo = sut.packageInfo;
      expect(context, mockRuleContext);
      expect(
        packageInfo,
        isA<PackageInfo>()
            .having((p) => p.name, 'name', isNull)
            .having((p) => p.location, 'location', compilationUnitParent),
      );
    },
  );

  test(
    'Should return default package-info if config source does not contain any value under `name` key',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('x: y');
      when(
        () => mockConfigSourceProvider.getConfigSource(
          mockWorkspacePackage,
          any(),
        ),
      ).thenReturn(mockConfigFile);

      sut.loadConfig(mockRuleContext);

      final context = sut.context;
      final packageInfo = sut.packageInfo;
      expect(context, mockRuleContext);
      expect(
        packageInfo,
        isA<PackageInfo>()
            .having((p) => p.name, 'name', isNull)
            .having((p) => p.location, 'location', compilationUnitParent),
      );
    },
  );

  test(
    'Should return package-info with real package name and package root location if all went well',
    () {
      const packageName = 'xyz';
      when(
        () => mockConfigFile.readAsStringSync(),
      ).thenReturn('name: $packageName');
      when(
        () => mockConfigSourceProvider.getConfigSource(
          mockWorkspacePackage,
          any(),
        ),
      ).thenReturn(mockConfigFile);

      sut.loadConfig(mockRuleContext);

      final context = sut.context;
      final packageInfo = sut.packageInfo;
      expect(context, mockRuleContext);
      expect(
        packageInfo,
        isA<PackageInfo>()
            .having((p) => p.name, 'name', packageName)
            .having((p) => p.location, 'location', packageRoot),
      );
    },
  );
}
