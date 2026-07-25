// ignore_for_file: avoid_dynamic_calls

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/clean_arch_linter_config.dart';
import 'package:clean_arch_linter/src/models/cross_layer_import_config.dart';
import 'package:clean_arch_linter/src/models/dart_sdk_import_config.dart';
import 'package:clean_arch_linter/src/models/default_config_options.dart';
import 'package:clean_arch_linter/src/models/domain_config.dart';
import 'package:clean_arch_linter/src/models/third_party_import_config.dart';
import 'package:clean_arch_linter/src/services/config/config_source_provider.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class CleanArchLinterConfigLoader
    extends ContextConfigLoader<CleanArchLinterConfig> {
  final DefaultConfigOptions _defaultConfigOptions;
  final ConfigSourceProvider _configSourceProvider;

  CleanArchLinterConfigLoader()
    : this._(
        DefaultConfigOptions(
          logConfig: LogConfig(
            logDirectoryRelativePathFromProjectRoot: path.joinAll([
              'logs',
              'analyzer_plugins',
              'clean_arch_linter',
            ]),
          ),
          scanConfig: const ScanConfig(),
          domainConfig: const DomainConfig(),
          dartSdkConfig: const DartSdkImportConfig(),
          crossLayerConfig: const CrossLayerImportConfig(),
          thirdPartyConfig: const ThirdPartyImportConfig(),
        ),
        ConfigSourceProviderImpl(),
      );

  @visibleForTesting
  CleanArchLinterConfigLoader.test(
    DefaultConfigOptions defaultConfigOptions,
    ConfigSourceProvider configSourceProvider,
  ) : this._(defaultConfigOptions, configSourceProvider);

  CleanArchLinterConfigLoader._(
    this._defaultConfigOptions,
    this._configSourceProvider,
  );

  @override
  CleanArchLinterConfig loadPluginConfig(
    RuleContext context,
    PackageInfo packageInfo,
  ) {
    final fallbackConfig = CleanArchLinterConfig(
      packageInfo: packageInfo,
      logConfig: _defaultConfigOptions.logConfig,
      scanConfig: _defaultConfigOptions.scanConfig,
      domainConfig: _defaultConfigOptions.domainConfig,
      dartSdkConfig: _defaultConfigOptions.dartSdkConfig,
      crossLayerConfig: _defaultConfigOptions.crossLayerConfig,
      thirdPartyConfig: _defaultConfigOptions.thirdPartyConfig,
    );

    if (packageInfo.name == null) {
      return fallbackConfig;
    }

    final pluginConfigFile = _configSourceProvider.getConfigSource(
      packageInfo,
      'clean_arch_linter_config.yaml',
    );
    if (!pluginConfigFile.existsSync()) {
      return fallbackConfig;
    }

    final parsedConfig = runCatching(
      () => loadYaml(pluginConfigFile.readAsStringSync()) as YamlMap?,
      defaultValue: null,
    );
    if (parsedConfig == null) {
      return fallbackConfig;
    }

    return CleanArchLinterConfig(
      packageInfo: packageInfo,
      logConfig: _extractLogConfig(parsedConfig),
      scanConfig: _extractScanConfig(parsedConfig),
      domainConfig: _extractDomainConfig(parsedConfig),
      dartSdkConfig: _extractDartSdkConfig(parsedConfig),
      crossLayerConfig: _extractCrossLayerConfig(parsedConfig),
      thirdPartyConfig: _extractThirdPartyConfig(parsedConfig),
    );
  }

  LogConfig _extractLogConfig(YamlMap rootConfigMap) {
    final logConfigYaml = runCatching(
      () => rootConfigMap['log_config'] as YamlMap?,
      defaultValue: null,
    );
    if (logConfigYaml == null) {
      return _defaultConfigOptions.logConfig;
    }

    final defaultLogDirectoryRelativePathFromProjectRoot =
        _defaultConfigOptions.logConfig.logDirectoryRelativePathFromProjectRoot;
    final defaultEnabledStatus = _defaultConfigOptions.logConfig.enabled;
    final defaultInfoLogAllowed = _defaultConfigOptions.logConfig.allowInfoLog;
    final defaultWarningLogAllowed =
        _defaultConfigOptions.logConfig.allowWarningLog;
    final defaultErrorLogAllowed =
        _defaultConfigOptions.logConfig.allowErrorLog;
    return LogConfig(
      enabled: runCatching(
        () => logConfigYaml['enabled'] as bool? ?? defaultEnabledStatus,
        defaultValue: defaultEnabledStatus,
      ),
      allowInfoLog: runCatching(
        () => logConfigYaml['allow_info'] as bool? ?? defaultInfoLogAllowed,
        defaultValue: defaultInfoLogAllowed,
      ),
      allowWarningLog: runCatching(
        () =>
            logConfigYaml['allow_warning'] as bool? ?? defaultWarningLogAllowed,
        defaultValue: defaultWarningLogAllowed,
      ),
      allowErrorLog: runCatching(
        () => logConfigYaml['allow_error'] as bool? ?? defaultErrorLogAllowed,
        defaultValue: defaultErrorLogAllowed,
      ),
      logDirectoryRelativePathFromProjectRoot: runCatching(
        () =>
            // Ensuring usage of platform path separator,
            // as this will be used to create actual file/folders.
            // Also, this is not used in analysis (which exclusively uses /).
            (logConfigYaml['log_dir_relative_path'] as String? ??
                    defaultLogDirectoryRelativePathFromProjectRoot)
                .normalizePathSeparators(pathSeparator: path.separator)
                .ensureTrailingPathSeparator(pathSeparator: path.separator),
        defaultValue: defaultLogDirectoryRelativePathFromProjectRoot,
      ),
    );
  }

  ScanConfig _extractScanConfig(YamlMap rootConfigMap) {
    final scanConfigYaml = runCatching(
      () => rootConfigMap['scan_config'] as YamlMap?,
      defaultValue: null,
    );
    if (scanConfigYaml == null) {
      return _defaultConfigOptions.scanConfig;
    }

    final defaultScanLibDirStatus = _defaultConfigOptions.scanConfig.scanLibDir;
    final defaultScanTestDirStatus =
        _defaultConfigOptions.scanConfig.scanTestDir;
    return ScanConfig(
      scanLibDir: runCatching(
        () =>
            scanConfigYaml['scan_lib_dir'] as bool? ?? defaultScanLibDirStatus,
        defaultValue: defaultScanLibDirStatus,
      ),
      scanTestDir: runCatching(
        () =>
            scanConfigYaml['scan_test_dir'] as bool? ??
            defaultScanTestDirStatus,
        defaultValue: defaultScanTestDirStatus,
      ),
    );
  }

  DomainConfig _extractDomainConfig(YamlMap rootConfigMap) {
    final domainConfigYaml = runCatching(
      () => rootConfigMap['domain_config'] as YamlMap?,
      defaultValue: null,
    );
    if (domainConfigYaml == null) {
      return _defaultConfigOptions.domainConfig;
    }

    final defaultDomainDirNames =
        _defaultConfigOptions.domainConfig.domainDirNames;

    return DomainConfig(
      domainDirNames: runCatching(
        () =>
            (domainConfigYaml['domain_dir_names'] as List?)?.cast<String>() ??
            defaultDomainDirNames,
        defaultValue: defaultDomainDirNames,
      ),
    );
  }

  DartSdkImportConfig _extractDartSdkConfig(YamlMap rootConfigMap) {
    final rulesYaml = runCatching(
      () => rootConfigMap['rules'] as YamlMap?,
      defaultValue: null,
    );
    final ruleYaml = runCatching(
      () => rulesYaml?['dart_sdk_import'] as YamlMap?,
      defaultValue: null,
    );
    if (ruleYaml == null) {
      return _defaultConfigOptions.dartSdkConfig;
    }

    return DartSdkImportConfig(
      excludedDartPackages: runCatching(
        () =>
            (ruleYaml['excluded_dart_packages'] as List?)?.cast<String>() ?? [],
        defaultValue: [],
      ),
    );
  }

  CrossLayerImportConfig _extractCrossLayerConfig(YamlMap rootConfigMap) {
    final rulesYaml = runCatching(
      () => rootConfigMap['rules'] as YamlMap?,
      defaultValue: null,
    );
    final ruleYaml = runCatching(
      () => rulesYaml?['cross_layer_import'] as YamlMap?,
      defaultValue: null,
    );
    if (ruleYaml == null) {
      return _defaultConfigOptions.crossLayerConfig;
    }

    return CrossLayerImportConfig(
      excludedProjectPaths: runCatching(
        () =>
            (ruleYaml['excluded_project_paths'] as List?)
                ?.cast<String>()
                .map(
                  (p) => p
                      .normalizePathSeparators(pathSeparator: '/')
                      .ensureTrailingPathSeparator(pathSeparator: '/'),
                )
                .toList() ??
            [],
        defaultValue: [],
      ),
    );
  }

  ThirdPartyImportConfig _extractThirdPartyConfig(YamlMap rootConfigMap) {
    final rulesYaml = runCatching(
      () => rootConfigMap['rules'] as YamlMap?,
      defaultValue: null,
    );
    final ruleYaml = runCatching(
      () => rulesYaml?['third_party_import'] as YamlMap?,
      defaultValue: null,
    );
    if (ruleYaml == null) {
      return _defaultConfigOptions.thirdPartyConfig;
    }

    return ThirdPartyImportConfig(
      excludedLibraryPackages: runCatching(
        () =>
            (ruleYaml['excluded_library_packages'] as List?)?.cast<String>() ??
            [],
        defaultValue: [],
      ),
    );
  }
}
