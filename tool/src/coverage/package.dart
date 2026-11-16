import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

YamlMap _readPubspec(String packageDir) =>
    loadYaml(File(p.join(packageDir, 'pubspec.yaml')).readAsStringSync())
        as YamlMap;

String _packageName(YamlMap pubspec) => pubspec['name'] as String;

bool _dependsOnFlutter(YamlMap pubspec) =>
    (pubspec['dependencies'] as YamlMap?)?['flutter'] != null;

/// The package the script runs in: the current folder.
class Package {
  /// The package's folder.
  final String dir;

  /// The package's name, from its pubspec.
  final String name;

  /// Whether the package depends on Flutter.
  final bool isFlutter;

  const Package({
    required this.dir,
    required this.name,
    required this.isFlutter,
  });

  /// The package in the current folder.
  factory Package.current() {
    final dir = Directory.current.path;
    final pubspec = _readPubspec(dir);
    return Package(
      dir: dir,
      name: _packageName(pubspec),
      isFlutter: _dependsOnFlutter(pubspec),
    );
  }
}
