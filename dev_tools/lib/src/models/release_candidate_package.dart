import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:meta/meta.dart';

@immutable
class ReleaseCandidatePackage {
  final String repoRootRelativePath;
  final PackageIdentity packageIdentity;
  final PublishedPackageInfo publishedPackageInfo;

  const ReleaseCandidatePackage({
    required this.repoRootRelativePath,
    required this.packageIdentity,
    required this.publishedPackageInfo,
  });

  @override
  String toString() => 'ReleaseCandidatePackage('
      'repoRootRelativePath: $repoRootRelativePath,'
      'packageIdentity: $packageIdentity,'
      'publishedPackageInfo: $publishedPackageInfo'
      ')';

  @override
  bool operator ==(Object other) =>
      other is ReleaseCandidatePackage &&
      other.repoRootRelativePath == repoRootRelativePath &&
      other.packageIdentity == packageIdentity;

  @override
  int get hashCode => Object.hash(repoRootRelativePath, packageIdentity);
}
