import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/package_identity_exception.dart';
import 'package:yaml/yaml.dart';

class ParsePubspecContent {
  const ParsePubspecContent();

  /// Parses a package identity out of pubspec.yaml content.
  ///
  /// Params:
  /// - `pubspecContent`: the raw contents of a pubspec.yaml file.
  ///
  /// Returns: a [PackageIdentity]. Its `version` is null when the pubspec
  /// has none — a valid state for an internal/unreleased package (e.g. an
  /// app), not an error.
  ///
  /// Throws:
  /// - [PackageIdentityException] when the content lacks a `name` — that's
  ///   the only thing that makes a pubspec unusable as a package identity.
  PackageIdentity call(String pubspecContent) {
    final pubspec = loadYaml(pubspecContent);
    final map = pubspec as YamlMap;

    final name = map['name']?.toString().trim() ?? '';
    if (name.isEmpty) {
      throw const PackageIdentityException('pubspec.yaml has no name.');
    }

    final publishTo = map['publish_to']?.toString().trim();
    final rawVersion = map['version']?.toString().trim();
    final version =
        (rawVersion == null || rawVersion.isEmpty) ? null : rawVersion;
    final isFlutterPackage = map.containsKey('flutter') ||
        _flutterSdkReferenced(map, 'environment') ||
        _flutterSdkReferenced(map, 'dependencies') ||
        _flutterSdkReferenced(map, 'dev_dependencies');

    return PackageIdentity(
      name: name,
      version: version,
      isFlutterPackage: isFlutterPackage,
      // See https://dart.dev/tools/pub/pubspec for more info
      // on when a package is considered to be a publishable package.
      isPublishable: publishTo != 'none' && version != null,
    );
  }

  static bool _flutterSdkReferenced(YamlMap map, String key) =>
      map[key] is YamlMap && (map[key] as YamlMap).containsKey('flutter');
}
