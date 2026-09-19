import 'dart:io';

import 'package:dev_tools/src/models/firebase_output_paths.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:yaml/yaml.dart';

/// Reads the templated Firebase output paths from the white-label project
/// config.
class ReadFirebaseOutputPaths {
  const ReadFirebaseOutputPaths();

  /// Reads configuration with this shape:
  /// ```yaml
  /// firebase:
  ///   output:
  ///     ios: ios/Config/Firebase/{flavor}/GoogleService-Info.plist
  ///     android: android/app/src/{flavor}/google-services.json
  ///     dart: lib/features/app/infrastructure/config/firebase/firebase_options_{flavor}.dart
  /// ```
  /// `{flavor}` is a literal placeholder, substituted later by the caller.
  /// Missing config, or a missing/non-string entry, falls back to the
  /// matching path in [FirebaseOutputPaths.defaults].
  Future<FirebaseOutputPaths> call(String projectPath) async {
    final file = File('$projectPath/${ReadWhitelabelConfig.fileName}');
    if (!file.existsSync()) return FirebaseOutputPaths.defaults;

    final dynamic document;
    try {
      document = loadYaml(await file.readAsString());
    } on YamlException {
      return FirebaseOutputPaths.defaults;
    }
    if (document is! YamlMap || document['firebase'] is! YamlMap) {
      return FirebaseOutputPaths.defaults;
    }

    final firebase = document['firebase'] as YamlMap;
    if (firebase['output'] is! YamlMap) return FirebaseOutputPaths.defaults;

    final output = firebase['output'] as YamlMap;
    const defaults = FirebaseOutputPaths.defaults;
    return FirebaseOutputPaths(
      ios: _stringOr(output['ios'], defaults.ios),
      android: _stringOr(output['android'], defaults.android),
      dart: _stringOr(output['dart'], defaults.dart),
    );
  }

  String _stringOr(dynamic value, String fallback) =>
      value is String && value.isNotEmpty ? value : fallback;
}
