import 'package:functions/functions.dart';
import 'package:generator_core/generator_core.dart';
import 'package:json_parser_generator/src/models/default_config_options.dart';
import 'package:json_parser_generator/src/models/json_parser_generator_context_config.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

class JsonParserGeneratorConfigLoader
    extends ContextConfigLoader<JsonParserGeneratorContextConfig> {
  final DefaultConfigOptions _defaultConfigOptions;

  JsonParserGeneratorConfigLoader(BuilderOptions builderOptions)
    : this._(
        builderOptions,
        DefaultConfigOptions(
          logConfig: LogConfig(
            logDirectoryRelativePathFromCurrentDir: path.joinAll([
              'logs',
              'generators',
              'json_parser_generator',
            ]),
          ),
        ),
      );

  @visibleForTesting
  JsonParserGeneratorConfigLoader.test(
    BuilderOptions builderOptions,
    DefaultConfigOptions defaultConfigOptions,
  ) : this._(builderOptions, defaultConfigOptions);

  JsonParserGeneratorConfigLoader._(
    super.builderOptions,
    this._defaultConfigOptions,
  );

  @override
  JsonParserGeneratorContextConfig loadPluginConfig(
    BuildStep buildStep,
    BuilderOptions builderOptions,
  ) {
    return JsonParserGeneratorContextConfig(
      logConfig: _extractLogConfig(builderOptions),
    );
  }

  LogConfig _extractLogConfig(BuilderOptions builderOptions) {
    final options = builderOptions.config;

    final logConfigMap = options['log_config'];
    if (logConfigMap is! Map) {
      return _defaultConfigOptions.logConfig;
    }

    final defaultLogDirectoryRelativePathFromCurrentDir =
        _defaultConfigOptions.logConfig.logDirectoryRelativePathFromCurrentDir;
    final defaultEnabledStatus = _defaultConfigOptions.logConfig.enabled;
    final defaultInfoLogAllowed = _defaultConfigOptions.logConfig.allowInfoLog;
    final defaultWarningLogAllowed =
        _defaultConfigOptions.logConfig.allowWarningLog;
    final defaultErrorLogAllowed =
        _defaultConfigOptions.logConfig.allowErrorLog;

    return LogConfig(
      enabled: runCatching(
        () => logConfigMap['enabled'] as bool? ?? defaultEnabledStatus,
        defaultValue: defaultEnabledStatus,
      ),
      allowInfoLog: runCatching(
        () => logConfigMap['allow_info'] as bool? ?? defaultInfoLogAllowed,
        defaultValue: defaultInfoLogAllowed,
      ),
      allowWarningLog: runCatching(
        () =>
            logConfigMap['allow_warning'] as bool? ?? defaultWarningLogAllowed,
        defaultValue: defaultWarningLogAllowed,
      ),
      allowErrorLog: runCatching(
        () => logConfigMap['allow_error'] as bool? ?? defaultErrorLogAllowed,
        defaultValue: defaultErrorLogAllowed,
      ),
      logDirectoryRelativePathFromCurrentDir: _normalizePath(
        runCatching(
          () =>
              logConfigMap['log_dir_relative_path'] as String? ??
              defaultLogDirectoryRelativePathFromCurrentDir,
          defaultValue: defaultLogDirectoryRelativePathFromCurrentDir,
        ),
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
