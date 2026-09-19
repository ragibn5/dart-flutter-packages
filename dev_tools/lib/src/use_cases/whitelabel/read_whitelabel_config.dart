import 'dart:io';

import 'package:dev_tools/src/models/firebase_flavor_config.dart';
import 'package:dev_tools/src/models/firebase_output_paths.dart';
import 'package:dev_tools/src/models/whitelabel_config.dart';
import 'package:yaml/yaml.dart';

/// Reads a white-label project's `dev_tools_whitelabel_config.yaml`, once,
/// into a single [WhitelabelConfig].
class ReadWhitelabelConfig {
  static const String fileName = 'dev_tools_whitelabel_config.yaml';

  const ReadWhitelabelConfig();

  /// Reads configuration with this shape (every key optional):
  /// ```yaml
  /// exclude:
  ///   - .dart_tool/**
  /// flavors: [dev, exp, stage, prod]
  /// firebase:
  ///   output:
  ///     ios: ios/Config/Firebase/{flavor}/GoogleService-Info.plist
  ///     android: android/app/src/{flavor}/google-services.json
  ///     dart: lib/features/app/infrastructure/config/firebase/firebase_options_{flavor}.dart
  ///   dev:
  ///     project_id: example-dev
  ///     ios_bundle_id: com.example.app.dev
  ///     android_package_name: com.example.app.dev
  /// splash:
  ///   config_file: flutter_native_splash-{flavor}.yaml
  /// ```
  /// `{flavor}` in `firebase.output.*` and `splash.config_file` is a literal
  /// placeholder, substituted later by the caller. Missing, malformed, or
  /// invalid entries fall back to the matching field of
  /// [WhitelabelConfig.empty].
  Future<WhitelabelConfig> call(String projectPath) async {
    final file = File('$projectPath/$fileName');
    if (!file.existsSync()) return WhitelabelConfig.empty;

    final dynamic document;
    try {
      document = loadYaml(await file.readAsString());
    } on YamlException {
      return WhitelabelConfig.empty;
    }
    if (document is! YamlMap) return WhitelabelConfig.empty;

    return WhitelabelConfig(
      exclude: _readExclude(document),
      flavors: _readFlavors(document),
      firebase: _readFirebase(document),
      firebaseOutputPaths: _readFirebaseOutputPaths(document),
      splashConfigPath: _readSplashConfigPath(document),
    );
  }

  List<String> _readExclude(YamlMap document) {
    if (document['exclude'] is! YamlList) return WhitelabelConfig.empty.exclude;
    return (document['exclude'] as YamlList)
        .map((entry) => entry.toString())
        .toList();
  }

  List<String> _readFlavors(YamlMap document) {
    if (document['flavors'] is! YamlList) {
      return WhitelabelConfig.empty.flavors;
    }
    final flavors = (document['flavors'] as YamlList)
        .map((entry) => entry.toString())
        .where((flavor) => flavor.isNotEmpty)
        .toList();
    return flavors.isEmpty ? WhitelabelConfig.empty.flavors : flavors;
  }

  Map<String, FirebaseFlavorConfig> _readFirebase(YamlMap document) {
    if (document['firebase'] is! YamlMap) return const {};

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

  FirebaseOutputPaths _readFirebaseOutputPaths(YamlMap document) {
    if (document['firebase'] is! YamlMap) return FirebaseOutputPaths.defaults;
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

  String _readSplashConfigPath(YamlMap document) {
    if (document['splash'] is! YamlMap) {
      return WhitelabelConfig.empty.splashConfigPath;
    }
    final configFile = (document['splash'] as YamlMap)['config_file'];
    return _stringOr(configFile, WhitelabelConfig.empty.splashConfigPath);
  }

  String _stringOr(dynamic value, String fallback) =>
      value is String && value.isNotEmpty ? value : fallback;
}
