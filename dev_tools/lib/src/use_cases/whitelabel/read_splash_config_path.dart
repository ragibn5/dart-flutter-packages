import 'dart:io';

import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:yaml/yaml.dart';

/// Reads the templated splash icon config file path from the white-label
/// project config.
class ReadSplashConfigPath {
  static const String defaultPath = 'flutter_native_splash-{flavor}.yaml';

  const ReadSplashConfigPath();

  /// Reads configuration with this shape:
  /// ```yaml
  /// splash:
  ///   config_file: flutter_native_splash-{flavor}.yaml
  /// ```
  /// `{flavor}` is a literal placeholder, substituted later by the caller.
  /// Missing config, or a missing/non-string `config_file`, falls back to
  /// [defaultPath].
  Future<String> call(String projectPath) async {
    final file = File('$projectPath/${ReadWhitelabelConfig.fileName}');
    if (!file.existsSync()) return defaultPath;

    final dynamic document;
    try {
      document = loadYaml(await file.readAsString());
    } on YamlException {
      return defaultPath;
    }
    if (document is! YamlMap || document['splash'] is! YamlMap) {
      return defaultPath;
    }

    final configFile = (document['splash'] as YamlMap)['config_file'];
    return configFile is String && configFile.isNotEmpty
        ? configFile
        : defaultPath;
  }
}
