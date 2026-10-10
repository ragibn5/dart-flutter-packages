import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/filter_touched_packages.dart';
import 'package:test/test.dart';

void main() {
  const sut = FilterTouchedPackages();

  ValidLocalPackageInfo pkg(String path) => ValidLocalPackageInfo(
        repoRootRelativePath: path,
        packageIdentity: PackageIdentity(name: path, version: '1.0.0'),
      );

  test('should return a package whose directory was changed directly', () {
    final result = sut(
      localPackages: [pkg('pkg_a')],
      changedFiles: ['pkg_a/lib/pkg_a.dart'],
    );

    expect(result, hasLength(1));
  });

  test('should return a package touched via a nested directory', () {
    final result = sut(
      localPackages: [pkg('packages/pkg_a')],
      changedFiles: ['packages/pkg_a/lib/pkg_a.dart'],
    );

    expect(result, hasLength(1));
  });

  test('should not return a package with no changed files under it', () {
    final result = sut(
      localPackages: [pkg('pkg_a')],
      changedFiles: ['docs/readme.md'],
    );

    expect(result, isEmpty);
  });

  test('should return only the packages actually touched among several', () {
    final result = sut(
      localPackages: [pkg('pkg_a'), pkg('pkg_b')],
      changedFiles: ['pkg_a/lib/pkg_a.dart'],
    );

    expect(result.map((p) => p.repoRootRelativePath), ['pkg_a']);
  });
}
