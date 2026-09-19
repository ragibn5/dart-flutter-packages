import 'dart:io';

import 'package:dev_tools/src/models/firebase_flavor_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_firebase_output_paths.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:yaml/yaml.dart';

/// Reads per-flavor Firebase settings from the white-label project config.
class ReadFirebaseConfig {
  const ReadFirebaseConfig();

  /// Reads configurations with this shape:
  /// ```yaml
  /// firebase:
  ///   dev:
  ///     project_id: example-dev
  ///     ios_bundle_id: com.example.app.dev
  ///     android_package_name: com.example.app.dev
  /// ```
  /// Invalid flavor entries are ignored. The `output` key is reserved for
  /// [ReadFirebaseOutputPaths] and is skipped here. Missing config returns an
  /// empty map.
  Future<Map<String, FirebaseFlavorConfig>> call(String projectPath) async {
    final file = File('$projectPath/${ReadWhitelabelConfig.fileName}');
    if (!file.existsSync()) return const {};

    final dynamic document;
    try {
      document = loadYaml(await file.readAsString());
    } on YamlException {
      return const {};
    }
    if (document is! YamlMap || document['firebase'] is! YamlMap) {
      return const {};
    }

    final configs = <String, FirebaseFlavorConfig>{};
    for (final entry in (document['firebase'] as YamlMap).entries) {
      if (entry.key.toString() == 'output') continue;
      final value = entry.value;
      if (value is! YamlMap) continue;
      final projectId = value['project_id'];
      final iosBundleId = value['ios_bundle_id'];
      final androidPackageName = value['android_package_name'];
      if (projectId is! String ||
          iosBundleId is! String ||
          androidPackageName is! String ||
          projectId.isEmpty ||
          iosBundleId.isEmpty ||
          androidPackageName.isEmpty) {
        continue;
      }
      configs[entry.key.toString()] = FirebaseFlavorConfig(
        projectId: projectId,
        iosBundleId: iosBundleId,
        androidPackageName: androidPackageName,
      );
    }
    return configs;
  }
}
