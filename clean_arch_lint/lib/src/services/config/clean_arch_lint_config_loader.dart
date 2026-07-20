// ignore_for_file: avoid_dynamic_calls

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/ddr_config.dart';
import 'package:clean_arch_lint/src/models/default_config_options.dart';
import 'package:clean_arch_lint/src/rules/dependency_direction_rule/dependency_direction_rule.dart';
import 'package:clean_arch_lint/src/services/config/config_source_provider.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class CleanArchLintConfigLoader extends ContextConfigLoader {
  final DefaultConfigOptions _defaultConfigOptions;
  final ConfigSourceProvider _configSourceProvider;

  CleanArchLintConfigLoader()
    : this._(
        DefaultConfigOptions(
          logConfig: LogConfig(
            logDirectoryRelativePathFromProjectRoot: path.joinAll([
              'logs',
              'analyzer_plugins',
              'clean_arch_lint',
            ]),
          ),
          scanConfig: const ScanConfig(),
          ddrConfig: const DependencyDirectionRuleConfig(),
        ),
        ConfigSourceProviderImpl(),
      );

  @visibleForTesting
  CleanArchLintConfigLoader.test(
    DefaultConfigOptions defaultConfigOptions,
    ConfigSourceProvider configSourceProvider,
  ) : this._(defaultConfigOptions, configSourceProvider);

  CleanArchLintConfigLoader._(
    this._defaultConfigOptions,
    this._configSourceProvider,
  );

  @override
  ContextConfig loadPluginConfig(RuleContext context, PackageInfo packageInfo) {
    final fallbackConfig = CleanArchLintConfig(
      packageInfo: packageInfo,
      logConfig: _defaultConfigOptions.logConfig,
      scanConfig: _defaultConfigOptions.scanConfig,
      ddrConfig: _defaultConfigOptions.ddrConfig,
    );

    if (packageInfo.name == null) {
      // If the context does not belong to a package
      // (e.g. standalone dart script etc), then will
      // use fallback config, as we are not expecting
      // any configuration file in non-package environment.
      return fallbackConfig;
    }

    final pluginConfigFile = _configSourceProvider.getConfigSource(
      packageInfo,
      'clean_arch_lint_config.yaml',
    );
    if (!pluginConfigFile.existsSync()) {
      // If the plugin config file doesn't exist, then will use fallback config.
      return fallbackConfig;
    }

    final parsedConfig = runCatching(
      () => loadYaml(pluginConfigFile.readAsStringSync()) as YamlMap?,
      defaultValue: null,
    );
    if (parsedConfig == null) {
      // If was not able to parse the config, then will use fallback config.
      return fallbackConfig;
    }

    return CleanArchLintConfig(
      packageInfo: packageInfo,
      logConfig: _extractLogConfig(parsedConfig),
      scanConfig: _extractScanConfig(parsedConfig),
      ddrConfig: _extractDDRConfig(parsedConfig),
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

  DependencyDirectionRuleConfig _extractDDRConfig(YamlMap rootConfigMap) {
    final ddrConfigYaml = runCatching(
      () =>
          rootConfigMap[DependencyDirectionRule.DDR_LINT_CODE.name] as YamlMap?,
      defaultValue: null,
    );
    if (ddrConfigYaml == null) {
      return _defaultConfigOptions.ddrConfig;
    }

    final defaultDomainDirNames =
        _defaultConfigOptions.ddrConfig.domainDirNames;
    final defaultCoreDartPackageExclusionStatus =
        _defaultConfigOptions.ddrConfig.excludeCoreDartPackages;

    return DependencyDirectionRuleConfig(
      domainDirNames: runCatching(
        () =>
            (ddrConfigYaml['domain_dir_names'] as List?)?.cast<String>() ??
            defaultDomainDirNames,
        defaultValue: defaultDomainDirNames,
      ),
      excludeCoreDartPackages: runCatching(
        () =>
            ddrConfigYaml['exclude_core_dart_packages'] as bool? ??
            defaultCoreDartPackageExclusionStatus,
        defaultValue: defaultCoreDartPackageExclusionStatus,
      ),
      excludedProjectPaths: runCatching(
        () =>
            (ddrConfigYaml['excluded_project_paths'] as List?)
                ?.cast<String>()
                .map(
                  // Ensuring usage of forward slash as the path separator.
                  // In Dart analysis, the forward slash (`/`) is the standard,
                  // and exclusive path separator.
                  (p) => p
                      .normalizePathSeparators(pathSeparator: '/')
                      .ensureTrailingPathSeparator(pathSeparator: '/'),
                )
                .toList() ??
            [],
        defaultValue: [],
      ),
      excludedLibraryPackages: runCatching(
        () =>
            (ddrConfigYaml['excluded_library_packages'] as List?)
                ?.cast<String>() ??
            [],
        defaultValue: [],
      ),
    );
  }
}
