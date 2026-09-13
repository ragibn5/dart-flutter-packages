import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/package_identity_exception.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/read_package_identity.dart';
import 'package:path/path.dart' as p;

/// Finds every package directory (one containing a `pubspec.yaml`) under a
/// repository root.
///
/// A directory whose pubspec can't even be read as a package identity (the
/// file is missing, or it lacks a `name`) is reported as a
/// [MalformedLocalPackageInfo] rather than failing the whole scan — that's a
/// genuinely broken package. A package with no `version` is NOT malformed:
/// it's a perfectly valid [ValidLocalPackageInfo] (e.g. an app, or another
/// internal, unreleased package) that just isn't a release candidate — see
/// [PackageIdentity.version]. Returns every resolvable package unfiltered —
/// narrowing down to whatever a caller actually needs (touched, publishable,
/// etc.) is the caller's job.
class FindPackages {
  /// Directories that never contain source packages worth scanning, and can
  /// be large enough to dominate the walk if not pruned (build output, caches,
  /// VCS metadata, IDE state etc.).
  static const _ignoredDirNames = {
    '.dart_tool',
    '.git',
    '.idea',
    '.pub-cache',
    '.symlinks',
    'build',
    'node_modules',
    'Pods',
  };

  final ReadPackageIdentity _readPackageIdentity;

  const FindPackages({
    ReadPackageIdentity readPackageIdentity = const ReadPackageIdentity(),
  }) : _readPackageIdentity = readPackageIdentity;

  /// Finds every package under [repoRoot].
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root to scan.
  ///
  /// Returns: every resolvable [ValidLocalPackageInfo] plus every
  /// [MalformedLocalPackageInfo] (in no particular order) — use `whereType` (or
  /// a `switch`) to separate them however the caller likes.
  ///
  /// Throws:
  /// - [PackageFinderException] when `repoRoot` does not exist.
  ///
  /// Notes: a package whose pubspec can't be read (see class docs) is
  /// reported as a [MalformedLocalPackageInfo], not thrown for.
  Future<List<PackageInfo>> call({required String repoRoot}) async {
    final repoRootDir = Directory(repoRoot);
    if (!repoRootDir.existsSync()) {
      throw PackageFinderException('Repository root not found: $repoRoot');
    }

    return Future.wait(
      _findPackageDirs(repoRootDir).map(
        (dir) => _buildPackageInfo(dir, p.relative(dir.path, from: repoRoot)),
      ),
    );
  }

  Iterable<Directory> _findPackageDirs(Directory dir) sync* {
    if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
      yield dir;
    }

    for (final entry in dir.listSync(followLinks: false)) {
      if (entry is Directory &&
          !_ignoredDirNames.contains(p.basename(entry.path))) {
        yield* _findPackageDirs(entry);
      }
    }
  }

  /// Builds a [PackageInfo] for [dir]: a [ValidLocalPackageInfo] when its
  /// pubspec resolves cleanly, otherwise a [MalformedLocalPackageInfo] capturing
  /// why (a missing or nameless pubspec.yaml) instead of letting the
  /// failure propagate.
  Future<PackageInfo> _buildPackageInfo(
    Directory dir,
    String repoRootRelativePath,
  ) async {
    try {
      return ValidLocalPackageInfo(
        repoRootRelativePath: repoRootRelativePath,
        packageIdentity: await _readPackageIdentity(dir.absolute.path),
      );
    } on PackageIdentityException catch (e) {
      return MalformedLocalPackageInfo(
        repoRootRelativePath: repoRootRelativePath,
        reason: e.message,
      );
    } catch (e) {
      return MalformedLocalPackageInfo(
        repoRootRelativePath: repoRootRelativePath,
        reason: e.toString(),
      );
    }
  }
}

class PackageFinderException extends CommandExecutionException {
  @override
  final String message;

  const PackageFinderException(this.message);
}
