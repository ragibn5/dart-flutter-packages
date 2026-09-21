import 'package:dev_tools/src/models/package_identity.dart';
import 'package:meta/meta.dart';

sealed class PackageInfo {
  final String repoRootRelativePath;

  const PackageInfo({required this.repoRootRelativePath});
}

@immutable
class ValidLocalPackageInfo extends PackageInfo {
  final PackageIdentity packageIdentity;

  const ValidLocalPackageInfo({
    required super.repoRootRelativePath,
    required this.packageIdentity,
  });

  @override
  String toString() => 'ValidLocalPackageInfo('
      'repoRootRelativePath: $repoRootRelativePath,'
      'packageIdentity: ${packageIdentity.name}@${packageIdentity.version},'
      ')';

  @override
  bool operator ==(Object other) =>
      other is ValidLocalPackageInfo &&
      other.repoRootRelativePath == repoRootRelativePath &&
      other.packageIdentity == packageIdentity;

  @override
  int get hashCode => Object.hash(repoRootRelativePath, packageIdentity);
}

@immutable
class MalformedLocalPackageInfo extends PackageInfo {
  final String reason;

  const MalformedLocalPackageInfo({
    required super.repoRootRelativePath,
    required this.reason,
  });

  @override
  String toString() =>
      'MalformedLocalPackageInfo(repoRootRelativePath: $repoRootRelativePath, '
      'reason: $reason)';

  @override
  bool operator ==(Object other) =>
      other is MalformedLocalPackageInfo &&
      other.repoRootRelativePath == repoRootRelativePath &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(repoRootRelativePath, reason);
}
