import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/read_package_identity.dart';
import 'package:path/path.dart' as p;

/// Resolves a given list of repo-root-relative package paths into their
/// [ValidLocalPackageInfo].
class ResolveLocalPackages {
  final ReadPackageIdentity _readPackageIdentity;

  const ResolveLocalPackages({
    ReadPackageIdentity readPackageIdentity = const ReadPackageIdentity(),
  }) : _readPackageIdentity = readPackageIdentity;

  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `packagePaths`: repo-root-relative paths of the packages to resolve.
  ///
  /// Returns: one [ValidLocalPackageInfo] per entry in [packagePaths], in
  /// the same order.
  ///
  /// Throws:
  /// - [PackageNotFoundException] when a path doesn't resolve to a package
  ///   with a valid pubspec.yaml.
  Future<List<ValidLocalPackageInfo>> call({
    required String repoRoot,
    required List<String> packagePaths,
  }) async {
    final packages = <ValidLocalPackageInfo>[];
    for (final path in packagePaths) {
      try {
        final identity = await _readPackageIdentity(p.join(repoRoot, path));
        packages.add(
          ValidLocalPackageInfo(
            repoRootRelativePath: path,
            packageIdentity: identity,
          ),
        );
      } on PackageIdentityException catch (e) {
        throw PackageNotFoundException('$path: ${e.message}');
      }
    }
    return packages;
  }
}

class PackageNotFoundException extends CommandExecutionException {
  @override
  final String message;

  const PackageNotFoundException(this.message);
}
