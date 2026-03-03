// ignore_for_file: avoid_dynamic_calls

import 'dart:io';

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/ddr_config.dart';
import 'package:clean_arch_lint/src/rules/dependency_direction_rule.dart';
import 'package:functions/functions.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class CleanArchLintConfigLoader extends ContextConfigLoader {
  @override
  ContextConfig loadPluginConfig(RuleContext context, PackageInfo packageInfo) {
    final defaultLogDirRelativePathFromProjectRoot = path.join(
      'logs',
      'analysis_plugins',
      'clean_arch_lint',
    );
    final fallbackConfig = CleanArchLintConfig(
      packageInfo: packageInfo,
      logConfig: LogConfig(
        logDirectoryRelativePathFromProjectRoot:
            defaultLogDirRelativePathFromProjectRoot,
      ),
    );

    if (packageInfo.name == null) {
      // If the context does not belong to a package
      // (e.g. standalone dart script etc), then will
      // use fallback config, as we are not expecting
      // any configuration file in non-package environment.
      return fallbackConfig;
    }

    final pluginConfigFile = File(
      path.join(packageInfo.location, 'clean_arch_lint_config.yaml'),
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
      ddrConfig: _extractDDRConfig(parsedConfig),
      scanConfig: _extractScanConfig(parsedConfig),
      logConfig: _extractLogConfig(
        parsedConfig,
        defaultLogDirRelativePathFromProjectRoot,
      ),
    );
  }

  LogConfig _extractLogConfig(
    YamlMap rootConfigMap,
    String defaultLogDirectoryRelativePathFromProjectRoot,
  ) {
    final logConfigYaml = runCatching(
      () => rootConfigMap['log_config'] as YamlMap?,
      defaultValue: null,
    );
    if (logConfigYaml == null) {
      return LogConfig(
        logDirectoryRelativePathFromProjectRoot:
            defaultLogDirectoryRelativePathFromProjectRoot,
      );
    }

    return LogConfig(
      enabled: runCatching(
        () => logConfigYaml['enabled'] as bool? ?? false,
        defaultValue: false,
      ),
      allowInfoLog: runCatching(
        () => logConfigYaml['allow_info'] as bool? ?? false,
        defaultValue: false,
      ),
      allowWarningLog: runCatching(
        () => logConfigYaml['allow_warning'] as bool? ?? false,
        defaultValue: false,
      ),
      allowErrorLog: runCatching(
        () => logConfigYaml['allow_error'] as bool? ?? true,
        defaultValue: true,
      ),
      logDirectoryRelativePathFromProjectRoot: runCatching(
        () =>
            (logConfigYaml['log_dir_relative_path'] as String?)?.replaceAll(
              '/',
              Platform.pathSeparator,
            ) ??
            defaultLogDirectoryRelativePathFromProjectRoot,
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
      return const ScanConfig();
    }

    return ScanConfig(
      scanLibDir: runCatching(
        () => scanConfigYaml['scan_lib_dir'] as bool? ?? true,
        defaultValue: true,
      ),
      scanTestDir: runCatching(
        () => scanConfigYaml['scan_test_dir'] as bool? ?? false,
        defaultValue: false,
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
      return const DependencyDirectionRuleConfig();
    }

    return DependencyDirectionRuleConfig(
      domainDirName: runCatching(
        () => ddrConfigYaml['domain_dir_name'] as String,
        defaultValue: 'domain',
      ),
      excludeCoreDartPackages: runCatching(
        () => ddrConfigYaml['exclude_core_dart_packages'] as bool,
        defaultValue: true,
      ),
      excludedProjectPaths: runCatching(
        () =>
            (ddrConfigYaml['excluded_project_paths'] as List?)
                ?.cast<String>() ??
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
