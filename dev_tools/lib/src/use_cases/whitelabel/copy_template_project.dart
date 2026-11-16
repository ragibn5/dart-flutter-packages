import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

/// Creates an independent project copy from a Flutter/Dart template.
class CopyTemplateProject {
  /// Project-root-relative glob patterns that should never be inherited.
  static const List<String> defaultExcludePatterns = ['.git'];

  final FindProjectRoot _findProjectRoot;
  final ReadWhitelabelConfig _readWhitelabelConfig;

  CopyTemplateProject({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
    ReadWhitelabelConfig readWhitelabelConfig = const ReadWhitelabelConfig(),
  })  : _findProjectRoot = findProjectRoot,
        _readWhitelabelConfig = readWhitelabelConfig;

  /// Copies [template] into [destination].
  ///
  /// The destination must not exist, unless it is empty and
  /// [allowExistingEmptyDirectory] is true. A destination inside the template
  /// is rejected to prevent recursively copying the template into itself.
  /// Project-specific exclusions are read from
  /// `dev_tools_whitelabel_config.yaml` in the template root. Its `exclude`
  /// entries are project-root-relative [Glob] patterns.
  Future<String> call({
    required String destination,
    String? template,
    bool allowExistingEmptyDirectory = false,
  }) async {
    final templateRoot = await _findProjectRoot(template);
    final source = Directory(templateRoot).absolute;
    final target = Directory(destination).absolute;

    if (_isSameOrDescendant(target.path, source.path)) {
      throw WhitelabelProjectException(
        'Destination must be outside the template project: ${target.path}',
      );
    }

    if (target.existsSync()) {
      final hasContents = target.listSync(followLinks: false).isNotEmpty;
      if (hasContents || !allowExistingEmptyDirectory) {
        throw WhitelabelProjectException(
          'Destination already exists: ${target.path}. '
          'Use --force only for an empty directory.',
        );
      }
    } else {
      await target.create(recursive: true);
    }

    final excludePatterns = <String>[
      ...defaultExcludePatterns,
      ...(await _readWhitelabelConfig(source.path)).exclude,
    ];
    final exclusions = excludePatterns
        .map((pattern) => pattern.replaceFirst(RegExp(r'/+$'), ''))
        .map(Glob.new)
        .toList();
    await for (final entity in source.list(followLinks: false)) {
      final relativePath = p.basename(entity.path);
      await _copyEntity(
        entity,
        p.join(target.path, relativePath),
        relativePath,
        exclusions,
      );
    }
    return target.path;
  }

  bool _isSameOrDescendant(String target, String source) {
    final relative = p.relative(target, from: source);
    return relative == '.' ||
        (!p.isAbsolute(relative) && !relative.startsWith('..${p.separator}'));
  }

  Future<void> _copyEntity(
    FileSystemEntity entity,
    String destination,
    String relativePath,
    List<Glob> exclusions,
  ) async {
    final normalizedPath = relativePath.replaceAll(r'\', '/');
    if (exclusions.any((glob) => glob.matches(normalizedPath))) return;

    if (entity is File) {
      await entity.copy(destination);
      return;
    }
    if (entity is Link) {
      await Link(destination).create(await entity.target());
      return;
    }
    if (entity is Directory) {
      await Directory(destination).create(recursive: true);
      await for (final child in entity.list(followLinks: false)) {
        final childName = p.basename(child.path);
        await _copyEntity(
          child,
          p.join(destination, childName),
          '$relativePath/$childName',
          exclusions,
        );
      }
    }
  }
}

class WhitelabelProjectException extends CommandExecutionException {
  @override
  final String message;

  const WhitelabelProjectException(this.message);
}
