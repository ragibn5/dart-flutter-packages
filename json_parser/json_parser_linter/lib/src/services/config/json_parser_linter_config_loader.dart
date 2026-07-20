// ignore_for_file: avoid_dynamic_calls

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:json_parser_linter/src/models/default_config_options.dart';
import 'package:json_parser_linter/src/models/json_parser_linter_config.dart';
import 'package:json_parser_linter/src/services/config/config_source_provider.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class JsonParserLinterConfigLoader extends ContextConfigLoader {
  final DefaultConfigOptions _defaultConfigOptions;
  final ConfigSourceProvider _configSourceProvider;

  JsonParserLinterConfigLoader()
    : this._(
        DefaultConfigOptions(
          logConfig: LogConfig(
            logDirectoryRelativePathFromProjectRoot: path.joinAll([
              'logs',
              'analyzer_plugins',
              'json_parser_linter',
            ]),
          ),
          scanConfig: const ScanConfig(),
        ),
        ConfigSourceProviderImpl(),
      );

  @visibleForTesting
  JsonParserLinterConfigLoader.test(
    DefaultConfigOptions defaultConfigOptions,
    ConfigSourceProvider configSourceProvider,
  ) : this._(defaultConfigOptions, configSourceProvider);

  JsonParserLinterConfigLoader._(
    this._defaultConfigOptions,
    this._configSourceProvider,
  );

  @override
  ContextConfig loadPluginConfig(RuleContext context, PackageInfo packageInfo) {
    final fallbackConfig = JsonParserLinterConfig(
      packageInfo: packageInfo,
      logConfig: _defaultConfigOptions.logConfig,
      scanConfig: _defaultConfigOptions.scanConfig,
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
      'json_parser_linter_config.yaml',
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

    return JsonParserLinterConfig(
      packageInfo: packageInfo,
      logConfig: _extractLogConfig(parsedConfig),
      scanConfig: _extractScanConfig(parsedConfig),
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
}
