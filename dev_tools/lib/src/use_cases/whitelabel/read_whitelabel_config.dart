import 'dart:io';

import 'package:dev_tools/src/models/firebase_flavor_config.dart';
import 'package:dev_tools/src/models/firebase_output_paths.dart';
import 'package:dev_tools/src/models/whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/whitelabel_config_exception.dart';
import 'package:yaml/yaml.dart';

/// Reads a white-label project's `dev_tools_whitelabel_config.yaml`, once,
/// into a single [WhitelabelConfig].
class ReadWhitelabelConfig {
  static const String fileName = 'dev_tools_whitelabel_config.yaml';

  static const WhitelabelConfig _unconfigured = WhitelabelConfig(
    exclude: [],
    flavors: null,
    firebase: {},
    firebaseOutputPaths: null,
  );

  const ReadWhitelabelConfig();

  /// Reads configuration with this shape:
  /// ```yaml
  /// exclude:                            # optional; default: no exclusions
  ///   - .dart_tool/**
  /// flavors: [dev, exp, stage, prod]    # optional; default: no flavors
  /// firebase:
  ///   output:                           # required once firebase is used
  ///     ios: ios/Config/Firebase/{flavor}/GoogleService-Info.plist
  ///     android: android/app/src/{flavor}/google-services.json
  ///     dart: lib/features/app/infrastructure/config/firebase/firebase_options_{flavor}.dart
  ///   dev:                              # one entry per declared flavor
  ///     project_id: example-dev
  ///     ios_bundle_id: com.example.app.dev
  ///     android_package_name: com.example.app.dev
  /// ```
  /// `{flavor}` in `firebase.output.*` is a literal placeholder, substituted
  /// later by the caller. A project with `flavors: []` declares a single
  /// `firebase.default` entry instead of one entry per flavor.
  ///
  /// `exclude` and `flavors` both have safe defaults: an absent `flavors:`
  /// key is treated the same as `flavors: []` (see [WhitelabelConfig]).
  ///
  /// `firebase`, once a project declares it at all, is validated eagerly,
  /// right here: `firebase.output` must be complete, and its per-flavor
  /// entries (or the single `default` entry, for a flavorless project) must
  /// exactly match `flavors` — no missing flavor, no extra/mistyped one.
  /// Any mismatch throws immediately, before the config is even returned,
  /// so a typo is caught the moment anything reads this file, not only when
  /// something happens to touch the specific flavor it broke.
  Future<WhitelabelConfig> call(String projectPath) async {
    final file = File('$projectPath/$fileName');
    if (!file.existsSync()) return _unconfigured;

    final dynamic document;
    try {
      document = loadYaml(await file.readAsString());
    } on YamlException {
      return _unconfigured;
    }
    if (document is! YamlMap) return _unconfigured;

    final flavors = _readFlavors(document);
    final firebaseSection = document['firebase'];

    var firebase = const <String, FirebaseFlavorConfig>{};
    FirebaseOutputPaths? firebaseOutputPaths;
    if (firebaseSection is YamlMap) {
      firebaseOutputPaths = _requireFirebaseOutputPaths(firebaseSection);
      firebase = _requireFirebaseFlavors(firebaseSection, flavors);
    }

    return WhitelabelConfig(
      exclude: _readExclude(document),
      flavors: flavors,
      firebase: firebase,
      firebaseOutputPaths: firebaseOutputPaths,
    );
  }

  List<String> _readExclude(YamlMap document) {
    if (document['exclude'] is! YamlList) return const [];
    return (document['exclude'] as YamlList)
        .map((entry) => entry.toString())
        .toList();
  }

  List<String>? _readFlavors(YamlMap document) {
    if (document['flavors'] is! YamlList) return const [];
    return (document['flavors'] as YamlList)
        .map((entry) => entry.toString())
        .where((flavor) => flavor.isNotEmpty)
        .toList();
  }

  FirebaseOutputPaths _requireFirebaseOutputPaths(YamlMap firebase) {
    if (firebase['output'] is! YamlMap) {
      throw const WhitelabelConfigException(
        "'firebase' is configured, but 'firebase.output' is missing. "
        'Declare ios/android/dart output path templates.',
      );
    }
    final output = firebase['output'] as YamlMap;
    return FirebaseOutputPaths(
      ios: _requireString(output, 'ios', 'firebase.output'),
      android: _requireString(output, 'android', 'firebase.output'),
      dart: _requireString(output, 'dart', 'firebase.output'),
    );
  }

  Map<String, FirebaseFlavorConfig> _requireFirebaseFlavors(
    YamlMap firebase,
    List<String>? flavors,
  ) {
    final keys = firebase.keys
        .map((key) => key.toString())
        .where((key) => key != 'output')
        .toSet();
    _validateFlavorKeys(sectionName: 'firebase', keys: keys, flavors: flavors);

    return {
      for (final key in keys)
        key: FirebaseFlavorConfig(
          projectId: _requireString(
            firebase[key] as YamlMap,
            'project_id',
            'firebase.$key',
          ),
          iosBundleId: _requireString(
            firebase[key] as YamlMap,
            'ios_bundle_id',
            'firebase.$key',
          ),
          androidPackageName: _requireString(
            firebase[key] as YamlMap,
            'android_package_name',
            'firebase.$key',
          ),
        ),
    };
  }

  /// Validates a per-flavor-keyed yaml section's [keys] against [flavors]:
  /// an exact match is required when there are flavors, or a single
  /// `default` key when [flavors] is empty. [flavors] being `null` (never
  /// declared) is itself an error, since a per-flavor section can't be
  /// validated without knowing the project's flavors.
  ///
  /// Reusable for any future per-flavor-keyed yaml section, not just
  /// `firebase`.
  void _validateFlavorKeys({
    required String sectionName,
    required Set<String> keys,
    required List<String>? flavors,
  }) {
    if (flavors == null) {
      throw WhitelabelConfigException(
        "'$sectionName' is configured, but 'flavors' isn't. Declare this "
        "project's flavors (flavors: [...], or flavors: [] if it has none) "
        'before configuring a per-flavor section like this one.',
      );
    }

    final expected = flavors.isEmpty ? {'default'} : flavors.toSet();
    final missing = expected.difference(keys);
    final extra = keys.difference(expected);
    if (missing.isEmpty && extra.isEmpty) return;

    final flavorsDescription = flavors.isEmpty
        ? '[] (expected a single "default" entry)'
        : flavors.toString();
    final parts = [
      if (missing.isNotEmpty) 'missing: ${missing.join(', ')}',
      if (extra.isNotEmpty)
        'unexpected (check for typos or stale flavors): ${extra.join(', ')}',
    ];
    throw WhitelabelConfigException(
      "'$sectionName' entries don't match flavors: $flavorsDescription — "
      '${parts.join('; ')}.',
    );
  }

  String _requireString(YamlMap map, String key, String context) {
    final value = map[key];
    if (value is! String || value.isEmpty) {
      throw WhitelabelConfigException(
        "'$context.$key' is missing in dev_tools_whitelabel_config.yaml.",
      );
    }
    return value;
  }
}
