import 'dart:io';

import 'package:yaml/yaml.dart';

/// Reads the current Dart/Flutter package name from a project's pubspec.
class GetCurrentDartPackage {
  const GetCurrentDartPackage();

  /// Reads the `name:` field from `pubspec.yaml` in [projectPath].
  ///
  /// Returns: the package name, or an empty string when it can't be
  /// determined (missing pubspec, malformed yaml, or a missing/non-string
  /// `name`).
  Future<String> call(String projectPath) async {
    final file = File('$projectPath/pubspec.yaml');
    if (!file.existsSync()) return '';

    final dynamic document;
    try {
      document = loadYaml(await file.readAsString());
    } on YamlException {
      return '';
    }
    if (document is! YamlMap) return '';

    final name = document['name'];
    return name is String ? name : '';
  }
}
