import 'dart:io';

import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

/// Deletes files and directories selected by a project's white-label config.
class CleanProjectArtifacts {
  final FindProjectRoot _findProjectRoot;
  final ReadWhitelabelConfig _readWhitelabelConfig;

  CleanProjectArtifacts({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
    ReadWhitelabelConfig readWhitelabelConfig = const ReadWhitelabelConfig(),
  })  : _findProjectRoot = findProjectRoot,
        _readWhitelabelConfig = readWhitelabelConfig;

  /// Deletes paths matched by `exclude` in the project config.
  Future<List<String>> call([String? project]) async {
    final root = Directory(await _findProjectRoot(project)).absolute;
    final exclusions = (await _readWhitelabelConfig(root.path))
        .map((pattern) => pattern.replaceFirst(RegExp(r'/+$'), ''))
        .map(Glob.new)
        .toList();
    return _cleanDirectory(root, root, exclusions);
  }

  Future<List<String>> _cleanDirectory(
    Directory root,
    Directory directory,
    List<Glob> exclusions,
  ) async {
    final removed = <String>[];
    await for (final entity in directory.list(followLinks: false)) {
      final relativePath =
          p.relative(entity.path, from: root.path).replaceAll(r'\', '/');
      if (exclusions.any((glob) => glob.matches(relativePath))) {
        await entity.delete(recursive: entity is Directory);
        removed.add(relativePath);
      } else if (entity is Directory) {
        removed.addAll(await _cleanDirectory(root, entity, exclusions));
      }
    }
    return removed;
  }
}
