// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/clean_arch_linter_config.dart';
import 'package:clean_arch_linter/src/models/cross_layer_import_config.dart';
import 'package:clean_arch_linter/src/models/dart_sdk_import_config.dart';
import 'package:clean_arch_linter/src/models/default_config_options.dart';
import 'package:clean_arch_linter/src/models/domain_config.dart';
import 'package:clean_arch_linter/src/models/third_party_import_config.dart';
import 'package:clean_arch_linter/src/services/config/clean_arch_linter_config_loader.dart';
import 'package:clean_arch_linter/src/services/config/config_source_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockRuleContext extends Mock implements RuleContext {}

class _MockPackageInfo extends Mock implements PackageInfo {}

class _MockConfigFile extends Mock implements File {}

class _MockLogConfig extends Mock implements LogConfig {}

class _MockScanConfig extends Mock implements ScanConfig {}

class _MockDomainConfig extends Mock implements DomainConfig {}

class _MockDartSDKImportConfig extends Mock implements DartSDKImportConfig {}

class _MockCrossLayerImportConfig extends Mock
    implements CrossLayerImportConfig {}

class _MockThirdPartyImportConfig extends Mock
    implements ThirdPartyImportConfig {}

class _MockDefaultConfigOptions extends Mock implements DefaultConfigOptions {}

class _MockConfigSourceProvider extends Mock implements ConfigSourceProvider {}

void main() {
  const packageName = 'xyz';
  const packageLocation = 'a/b/c';
  const defaultLogDirectoryRelativePathFromProjectRoot =
      'logs/analysis_plugins/clean_arch_linter';

  const defaultLogEnabled = false;
  const defaultAllowInfoLog = false;
  const defaultAllowWarningLog = false;
  const defaultAllowErrorLog = true;
  const defaultScanLibDir = true;
  const defaultScanTestDir = false;
  const defaultDomainDirNames = ['domain'];
  const defaultExcludedDartPackages = <String>[];
  const defaultExcludedProjectPaths = <String>[];
  const defaultExcludedLibraryPackages = <String>[];

  late _MockRuleContext mockRuleContext;
  late _MockPackageInfo mockPackageInfo;
  late _MockConfigFile mockConfigFile;
  late _MockLogConfig mockDefaultLogConfig;
  late _MockScanConfig mockDefaultScanConfig;
  late _MockDomainConfig mockDefaultDomainConfig;
  late _MockDartSDKImportConfig mockDefaultDartSDKConfig;
  late _MockCrossLayerImportConfig mockDefaultCrossLayerConfig;
  late _MockThirdPartyImportConfig mockDefaultThirdPartyConfig;
  late _MockDefaultConfigOptions mockDefaultConfigOptions;
  late _MockConfigSourceProvider mockConfigSourceProvider;

  late CleanArchLinterConfigLoader sut;

  setUp(() {
    mockRuleContext = _MockRuleContext();
    mockPackageInfo = _MockPackageInfo();
    mockConfigFile = _MockConfigFile();
    mockDefaultLogConfig = _MockLogConfig();
    mockDefaultScanConfig = _MockScanConfig();
    mockDefaultDomainConfig = _MockDomainConfig();
    mockDefaultDartSDKConfig = _MockDartSDKImportConfig();
    mockDefaultCrossLayerConfig = _MockCrossLayerImportConfig();
    mockDefaultThirdPartyConfig = _MockThirdPartyImportConfig();
    mockDefaultConfigOptions = _MockDefaultConfigOptions();
    mockConfigSourceProvider = _MockConfigSourceProvider();

    sut = CleanArchLinterConfigLoader.test(
      mockDefaultConfigOptions,
      mockConfigSourceProvider,
    );

    when(() => mockPackageInfo.name).thenReturn(packageName);
    when(() => mockPackageInfo.location).thenReturn(packageLocation);
    when(() => mockConfigFile.existsSync()).thenReturn(true);
    when(
      () => mockDefaultConfigOptions.logConfig,
    ).thenReturn(mockDefaultLogConfig);
    when(() => mockDefaultLogConfig.enabled).thenReturn(defaultLogEnabled);
    when(
      () => mockDefaultLogConfig.allowInfoLog,
    ).thenReturn(defaultAllowInfoLog);
    when(
      () => mockDefaultLogConfig.allowWarningLog,
    ).thenReturn(defaultAllowWarningLog);
    when(
      () => mockDefaultLogConfig.allowErrorLog,
    ).thenReturn(defaultAllowErrorLog);
    when(
      () => mockDefaultLogConfig.logDirectoryRelativePathFromProjectRoot,
    ).thenReturn(defaultLogDirectoryRelativePathFromProjectRoot);
    when(
      () => mockDefaultConfigOptions.scanConfig,
    ).thenReturn(mockDefaultScanConfig);
    when(() => mockDefaultScanConfig.scanLibDir).thenReturn(defaultScanLibDir);
    when(
      () => mockDefaultScanConfig.scanTestDir,
    ).thenReturn(defaultScanTestDir);
    when(
      () => mockDefaultConfigOptions.domainConfig,
    ).thenReturn(mockDefaultDomainConfig);
    when(
      () => mockDefaultDomainConfig.domainDirNames,
    ).thenReturn(defaultDomainDirNames);
    when(
      () => mockDefaultConfigOptions.dartSDKConfig,
    ).thenReturn(mockDefaultDartSDKConfig);
    when(
      () => mockDefaultDartSDKConfig.excludedDartPackages,
    ).thenReturn(defaultExcludedDartPackages);
    when(
      () => mockDefaultConfigOptions.crossLayerConfig,
    ).thenReturn(mockDefaultCrossLayerConfig);
    when(
      () => mockDefaultCrossLayerConfig.excludedProjectPaths,
    ).thenReturn(defaultExcludedProjectPaths);
    when(
      () => mockDefaultConfigOptions.thirdPartyConfig,
    ).thenReturn(mockDefaultThirdPartyConfig);
    when(
      () => mockDefaultThirdPartyConfig.excludedLibraryPackages,
    ).thenReturn(defaultExcludedLibraryPackages);
    when(
      () => mockConfigSourceProvider.getConfigSource(mockPackageInfo, any()),
    ).thenReturn(mockConfigFile);
  });

  void expectDefaultConfig(ContextConfig config) {
    expect(
      config,
      isA<CleanArchLinterConfig>()
          .having((p) => p.packageInfo, 'packageInfo', mockPackageInfo)
          .having((p) => p.logConfig, 'logConfig', mockDefaultLogConfig)
          .having((p) => p.scanConfig, 'scanConfig', mockDefaultScanConfig)
          .having(
            (p) => p.domainConfig,
            'domainConfig',
            mockDefaultDomainConfig,
          )
          .having(
            (p) => p.dartSDKConfig,
            'dartSDKConfig',
            mockDefaultDartSDKConfig,
          )
          .having(
            (p) => p.crossLayerConfig,
            'crossLayerConfig',
            mockDefaultCrossLayerConfig,
          )
          .having(
            (p) => p.thirdPartyConfig,
            'thirdPartyConfig',
            mockDefaultThirdPartyConfig,
          ),
    );
  }

  test(
    'If the context does not belong to a package, will use fallback config',
    () {
      when(() => mockPackageInfo.name).thenReturn(null);

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expectDefaultConfig(config);
    },
  );

  test('If the config file does not exist, will use fallback config', () {
    when(() => mockConfigFile.existsSync()).thenReturn(false);

    final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

    expectDefaultConfig(config);
  });

  test('If the config file returns empty string, will use fallback config', () {
    when(() => mockConfigFile.readAsStringSync()).thenReturn('');

    final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

    expectDefaultConfig(config);
  });

  test('If the config file returns invalid yaml, will use fallback config', () {
    when(() => mockConfigFile.readAsStringSync()).thenReturn('Hello-World');

    final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

    expectDefaultConfig(config);
  });

  test(
    'If all went well, and config sections are not present, will use default configs',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('x: y');

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expectDefaultConfig(config);
    },
  );

  test(
    'If all went well, and config sections are not in valid format, will use default configs',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('''
      log_config: x
      scan_config: y
      domain_config: z
      rules: w
      ''');

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expectDefaultConfig(config);
    },
  );

  test(
    'If all went well, and config sections are in valid format, use appropriate values',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('''
      log_config:
        enabled: true
        allow_info: true
        allow_warning: true
        allow_error: true
        log_dir_relative_path: analysis_logs/analysis_plugins/clean_arch_linter/
  
      scan_config:
        scan_lib_dir: true
        scan_test_dir: true
    
      domain_config:
        domain_dir_names:
          - dmn
    
      rules:
        dart_sdk_import:
          excluded_dart_packages:
            - dart:core
        cross_layer_import:
          excluded_project_paths:
            - /core/
            - /shard/
        third_party_import:
          excluded_library_packages:
            - freezed
            - equatable
      ''');

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expect(
        config,
        isA<CleanArchLinterConfig>()
            .having((p) => p.packageInfo, 'packageInfo', mockPackageInfo)
            .having((p) => p.logConfig.enabled, 'logConfig.enabled', true)
            .having(
              (p) => p.logConfig.allowInfoLog,
              'logConfig.allowInfoLog',
              true,
            )
            .having(
              (p) => p.logConfig.allowWarningLog,
              'logConfig.allowWarningLog',
              true,
            )
            .having(
              (p) => p.logConfig.allowErrorLog,
              'logConfig.allowErrorLog',
              true,
            )
            .having(
              (p) => p.logConfig.logDirectoryRelativePathFromProjectRoot,
              'logConfig.logDirectoryRelativePathFromProjectRoot',
              'analysis_logs/analysis_plugins/clean_arch_linter/',
            )
            .having(
              (p) => p.scanConfig.scanLibDir,
              'scanConfig.scanLibDir',
              true,
            )
            .having(
              (p) => p.scanConfig.scanTestDir,
              'scanConfig.scanTestDir',
              true,
            )
            .having(
              (p) => p.domainConfig.domainDirNames,
              'domainConfig.domainDirNames',
              ['dmn'],
            )
            .having(
              (p) => p.dartSDKConfig.excludedDartPackages,
              'dartSDKConfig.excludedDartPackages',
              ['dart:core'],
            )
            .having(
              (p) => p.crossLayerConfig.excludedProjectPaths,
              'crossLayerConfig.excludedProjectPaths',
              ['/core/', '/shard/'],
            )
            .having(
              (p) => p.thirdPartyConfig.excludedLibraryPackages,
              'thirdPartyConfig.excludedLibraryPackages',
              ['freezed', 'equatable'],
            ),
      );
    },
  );

  test(
    'If all went well, and config sections contain invalid platform separator, it is auto fixed',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn(r'''
      log_config:
        log_dir_relative_path: analysis_logs\analysis_plugins\clean_arch_linter
    
      rules:
        cross_layer_import:
          excluded_project_paths:
            - core\
            - shard\
        third_party_import:
          excluded_library_packages:
            - freezed
            - equatable
      ''');

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expect(
        config,
        isA<CleanArchLinterConfig>()
            .having((p) => p.packageInfo, 'packageInfo', mockPackageInfo)
            .having(
              (p) => p.logConfig.logDirectoryRelativePathFromProjectRoot,
              'logConfig.logDirectoryRelativePathFromProjectRoot',
              'analysis_logs/analysis_plugins/clean_arch_linter/',
            )
            .having(
              (p) => p.crossLayerConfig.excludedProjectPaths,
              'crossLayerConfig.excludedProjectPaths',
              ['core/', 'shard/'],
            ),
      );
    },
  );

  test(
    'If all went well, and config sections are in invalid format, use default values',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('''
      log_config:
        enabled: 1
        allow_info: 2
        allow_warning: 3
        allow_error: 4
  
      scan_config:
        scan_lib_dir: 1
        scan_test_dir: 2
    
      domain_config:
        domain_dir_names: dmn
    
      rules:
        dart_sdk_import:
          excluded_dart_packages: 1
        cross_layer_import:
          excluded_project_paths: 1
        third_party_import:
          excluded_library_packages: 2
      ''');

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expect(
        config,
        isA<CleanArchLinterConfig>()
            .having((p) => p.packageInfo, 'packageInfo', mockPackageInfo)
            .having(
              (p) => p.logConfig.enabled,
              'logConfig.enabled',
              defaultLogEnabled,
            )
            .having(
              (p) => p.logConfig.allowInfoLog,
              'logConfig.allowInfoLog',
              defaultAllowInfoLog,
            )
            .having(
              (p) => p.logConfig.allowWarningLog,
              'logConfig.allowWarningLog',
              defaultAllowWarningLog,
            )
            .having(
              (p) => p.logConfig.allowErrorLog,
              'logConfig.allowErrorLog',
              defaultAllowErrorLog,
            )
            .having(
              (p) => p.scanConfig.scanLibDir,
              'scanConfig.scanLibDir',
              defaultScanLibDir,
            )
            .having(
              (p) => p.scanConfig.scanTestDir,
              'scanConfig.scanTestDir',
              defaultScanTestDir,
            )
            .having(
              (p) => p.dartSDKConfig.excludedDartPackages,
              'dartSDKConfig.excludedDartPackages',
              defaultExcludedDartPackages,
            )
            .having(
              (p) => p.crossLayerConfig.excludedProjectPaths,
              'crossLayerConfig.excludedProjectPaths',
              defaultExcludedProjectPaths,
            )
            .having(
              (p) => p.thirdPartyConfig.excludedLibraryPackages,
              'thirdPartyConfig.excludedLibraryPackages',
              defaultExcludedLibraryPackages,
            ),
      );
    },
  );
}
