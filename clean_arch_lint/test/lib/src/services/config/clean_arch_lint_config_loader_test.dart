// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/ddr_config.dart';
import 'package:clean_arch_lint/src/models/default_config_options.dart';
import 'package:clean_arch_lint/src/services/config/clean_arch_lint_config_loader.dart';
import 'package:clean_arch_lint/src/services/config/config_source_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockRuleContext extends Mock implements RuleContext {}

class _MockPackageInfo extends Mock implements PackageInfo {}

class _MockConfigFile extends Mock implements File {}

class _MockLogConfig extends Mock implements LogConfig {}

class _MockScanConfig extends Mock implements ScanConfig {}

class _MockDDRConfig extends Mock implements DependencyDirectionRuleConfig {}

class _MockDefaultConfigOptions extends Mock implements DefaultConfigOptions {}

class _MockConfigSourceProvider extends Mock implements ConfigSourceProvider {}

void main() {
  // Default config = default-log-dir-relative-path-parts + passed-package-config

  const packageName = 'xyz';
  const packageLocation = 'a/b/c';
  const defaultLogDirectoryRelativePathFromProjectRoot =
      'logs/analysis_plugins/clean_arch_lint';

  const defaultLogEnabled = false;
  const defaultAllowInfoLog = false;
  const defaultAllowWarningLog = false;
  const defaultAllowErrorLog = true;
  const defaultScanLibDir = true;
  const defaultScanTestDir = false;
  const defaultDomainDirName = 'domain';
  const defaultExcludeCoreDartPackages = true;
  const defaultExcludedProjectPaths = <String>[];
  const defaultExcludedLibraryPackages = <String>[];

  late _MockRuleContext mockRuleContext;
  late _MockPackageInfo mockPackageInfo;
  late _MockConfigFile mockConfigFile;
  late _MockLogConfig mockDefaultLogConfig;
  late _MockScanConfig mockDefaultScanConfig;
  late _MockDDRConfig mockDefaultDDRConfig;
  late _MockDefaultConfigOptions mockDefaultConfigOptions;
  late _MockConfigSourceProvider mockConfigSourceProvider;

  late CleanArchLintConfigLoader sut;

  setUp(() {
    mockRuleContext = _MockRuleContext();
    mockPackageInfo = _MockPackageInfo();
    mockConfigFile = _MockConfigFile();
    mockDefaultLogConfig = _MockLogConfig();
    mockDefaultScanConfig = _MockScanConfig();
    mockDefaultDDRConfig = _MockDDRConfig();
    mockDefaultConfigOptions = _MockDefaultConfigOptions();
    mockConfigSourceProvider = _MockConfigSourceProvider();

    sut = CleanArchLintConfigLoader.test(
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
      () => mockDefaultConfigOptions.ddrConfig,
    ).thenReturn(mockDefaultDDRConfig);
    when(
      () => mockDefaultDDRConfig.domainDirName,
    ).thenReturn(defaultDomainDirName);
    when(
      () => mockDefaultDDRConfig.excludeCoreDartPackages,
    ).thenReturn(defaultExcludeCoreDartPackages);
    when(
      () => mockDefaultDDRConfig.excludeCoreDartPackages,
    ).thenReturn(defaultExcludeCoreDartPackages);
    when(
      () => mockConfigSourceProvider.getConfigSource(mockPackageInfo, any()),
    ).thenReturn(mockConfigFile);
  });

  void expectDefaultConfig(ContextConfig config) {
    expect(
      config,
      isA<CleanArchLintConfig>()
          .having((p) => p.packageInfo, 'packageInfo', mockPackageInfo)
          .having((p) => p.logConfig, 'logConfig', mockDefaultLogConfig)
          .having((p) => p.scanConfig, 'scanConfig', mockDefaultScanConfig)
          .having((p) => p.ddrConfig, 'ddrConfig', mockDefaultDDRConfig),
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
    'If all went well, and log/scan/ddr config is not present, will use default configs',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('x: y');

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expectDefaultConfig(config);
    },
  );

  test(
    'If all went well, and log/scan/ddr config is not in valid format, will use default configs',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('''
      log_config: x
      scan_config: y
      clean_arch_dependency_direction: z
      ''');

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expectDefaultConfig(config);
    },
  );

  test(
    'If all went well, and log/scan/ddr config is in valid format, use appropriate values',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('''
      log_config:
        enabled: true
        allow_info: true
        allow_warning: true
        allow_error: true
        log_dir_relative_path: analysis_logs/analysis_plugins/clean_arch_lint/
  
      scan_config:
        scan_lib_dir: true
        scan_test_dir: true
    
      clean_arch_dependency_direction:
        domain_dir_name: dmn
        exclude_core_dart_packages: false
        excluded_project_paths:
          - /core/
          - /shard/
        excluded_library_packages:
          - freezed
          - equatable
      ''');

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expect(
        config,
        isA<CleanArchLintConfig>()
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
              'analysis_logs/analysis_plugins/clean_arch_lint/',
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
              (p) => p.ddrConfig.domainDirName,
              'ddrConfig.domainDirName',
              'dmn',
            )
            .having(
              (p) => p.ddrConfig.excludeCoreDartPackages,
              'ddrConfig.excludeCoreDartPackages',
              false,
            )
            .having(
              (p) => p.ddrConfig.excludedProjectPaths,
              'ddrConfig.excludedProjectPaths',
              ['/core/', '/shard/'],
            )
            .having(
              (p) => p.ddrConfig.excludedLibraryPackages,
              'ddrConfig.excludedLibraryPackages',
              ['freezed', 'equatable'],
            ),
      );
    },
  );

  test(
    'If all went well, and log/scan/ddr config contains invalid platform separator, it is auto fixed',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn(r'''
      log_config:
        log_dir_relative_path: analysis_logs\analysis_plugins\clean_arch_lint
    
      clean_arch_dependency_direction:
        excluded_project_paths:
          - core\
          - shard\
        excluded_library_packages:
          - freezed
          - equatable
      ''');

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expect(
        config,
        isA<CleanArchLintConfig>()
            .having((p) => p.packageInfo, 'packageInfo', mockPackageInfo)
            .having(
              (p) => p.logConfig.logDirectoryRelativePathFromProjectRoot,
              'logConfig.logDirectoryRelativePathFromProjectRoot',
              path.join('analysis_logs', 'analysis_plugins', 'clean_arch_lint'),
            )
            .having(
              (p) => p.ddrConfig.excludedProjectPaths,
              'ddrConfig.excludedProjectPaths',
              ['core${path.separator}', 'shard${path.separator}'],
            ),
      );
    },
  );

  test(
    'If all went well, and log/scan/ddr config is in invalid format, use default values',
    () {
      when(() => mockConfigFile.readAsStringSync()).thenReturn('''
      log_config:
        enabled: 1
        allow_info: 2
        allow_warning: 3
        allow_error: 4
        # log_dir_relative_path: analysis_logs/analysis_plugins/clean_arch_lint
  
      scan_config:
        scan_lib_dir: 1
        scan_test_dir: 2
    
      clean_arch_dependency_direction:
        # domain_dir_name: dmn
        exclude_core_dart_packages: 1
        excluded_project_paths: 1
        excluded_library_packages: 2
      ''');

      final config = sut.loadPluginConfig(mockRuleContext, mockPackageInfo);

      expect(
        config,
        isA<CleanArchLintConfig>()
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
              (p) => p.ddrConfig.excludeCoreDartPackages,
              'ddrConfig.excludeCoreDartPackages',
              defaultExcludeCoreDartPackages,
            )
            .having(
              (p) => p.ddrConfig.excludedProjectPaths,
              'ddrConfig.excludedProjectPaths',
              defaultExcludedProjectPaths,
            )
            .having(
              (p) => p.ddrConfig.excludedLibraryPackages,
              'ddrConfig.excludedLibraryPackages',
              defaultExcludedLibraryPackages,
            ),
      );
    },
  );
}
