import 'dart:io';

import 'package:yaml/yaml.dart';

/// Reads white-label creation settings from the template project itself.
class ReadWhitelabelConfig {
  static const String fileName = 'dev_tools_whitelabel_config.yaml';

  const ReadWhitelabelConfig();

  /// Returns project-root-relative glob patterns excluded during creation.
  ///
  /// The optional config file uses this shape:
  /// ```yaml
  /// exclude:
  ///   - .dart_tool/**
  ///   - android/build/**
  ///   - **/*.iml
  /// ```
  /// Missing, malformed, or non-list `exclude` values mean no project-specific
  /// exclusions.
  Future<List<String>> call(String projectPath) async {
    final file = File('$projectPath/$fileName');
    if (!file.existsSync()) {
      return const [];
    }

    final dynamic document;
    try {
      document = loadYaml(await file.readAsString());
    } on YamlException {
      return const [];
    }
    if (document is! YamlMap || document['exclude'] is! YamlList) {
      return const [];
    }

    return (document['exclude'] as YamlList)
        .map((entry) => entry.toString())
        .toList();
  }
}
