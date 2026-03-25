import 'package:generator_core/generator_core.dart';
import 'package:json_parser_generator/src/models/json_parser_generator_context_config.dart';
import 'package:path/path.dart' as path;

class JsonParserGeneratorConfigLoader
    extends ContextConfigLoader<JsonParserGeneratorContextConfig> {
  JsonParserGeneratorConfigLoader(super.builderOptions);

  @override
  JsonParserGeneratorContextConfig loadPluginConfig(
    BuildStep buildStep,
    BuilderOptions builderOptions,
    PackageInfo packageInfo,
  ) {
    return JsonParserGeneratorContextConfig(
      packageInfo: packageInfo,
      logConfig: _extractLogConfig(builderOptions),
    );
  }

  LogConfig _extractLogConfig(BuilderOptions builderOptions) {
    final options = builderOptions.config;

    final defaultLogDir = path.joinAll([
      'logs',
      'generators',
      'json_parser_generator',
    ]);

    final logConfigMap = options['log_config'];
    if (logConfigMap is! Map) {
      return LogConfig(logDirectoryRelativePathFromProjectRoot: defaultLogDir);
    }

    return LogConfig(
      enabled: logConfigMap['enabled'] as bool? ?? true,
      allowInfoLog: logConfigMap['allow_info'] as bool? ?? true,
      allowWarningLog: logConfigMap['allow_warning'] as bool? ?? true,
      allowErrorLog: logConfigMap['allow_error'] as bool? ?? true,
      logDirectoryRelativePathFromProjectRoot:
          logConfigMap['log_dir_relative_path'] as String? ?? defaultLogDir,
    );
  }
}
