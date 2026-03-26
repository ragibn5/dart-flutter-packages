// ignore_for_file: avoid_dynamic_calls

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:functions/functions.dart';
import 'package:json_parser_analyzer/src/models/default_config_options.dart';
import 'package:json_parser_analyzer/src/models/json_parser_lint_config.dart';
import 'package:json_parser_analyzer/src/services/config/config_source_provider.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class JsonParserLintConfigLoader extends ContextConfigLoader {
  final DefaultConfigOptions _defaultConfigOptions;
  final ConfigSourceProvider _configSourceProvider;

  JsonParserLintConfigLoader()
    : this._(
        DefaultConfigOptions(
          logConfig: LogConfig(
            logDirectoryRelativePathFromProjectRoot: path.joinAll([
              'logs',
              'analyzer_plugins',
              'json_parser_lint',
            ]),
          ),
          scanConfig: const ScanConfig(),
        ),
        ConfigSourceProviderImpl(),
      );

  @visibleForTesting
  JsonParserLintConfigLoader.test(
    DefaultConfigOptions defaultConfigOptions,
    ConfigSourceProvider configSourceProvider,
  ) : this._(defaultConfigOptions, configSourceProvider);

  JsonParserLintConfigLoader._(
    this._defaultConfigOptions,
    this._configSourceProvider,
  );

  @override
  ContextConfig loadPluginConfig(RuleContext context, PackageInfo packageInfo) {
    final fallbackConfig = JsonParserLintConfig(
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
      'json_parser_lint_config.yaml',
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

    return JsonParserLintConfig(
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
        () => _normalizePath(
          logConfigYaml['log_dir_relative_path'] as String? ??
              defaultLogDirectoryRelativePathFromProjectRoot,
        ),
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

  String _normalizePath(String filePath) {
    final platformSeparatorFixedPath = filePath.replaceAll(
      RegExp(r'[\\/]'),
      path.separator,
    );

    final normalizedFixedPath = path.normalize(platformSeparatorFixedPath);
    final normalizedPathSuffix =
        platformSeparatorFixedPath.endsWith(path.separator)
        ? path.separator
        : '';

    return '$normalizedFixedPath$normalizedPathSuffix';
  }
}
