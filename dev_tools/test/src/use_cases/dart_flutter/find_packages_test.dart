import 'dart:io';

import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  late FindPackages sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('find_packages_test');
    sut = const FindPackages();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  void writePubspec(String relativeDir, String content) {
    final dir = Directory('${tempDir.path}/$relativeDir')
      ..createSync(recursive: true);
    File('${dir.path}/pubspec.yaml').writeAsStringSync(content);
  }

  test('should find every package with a readable pubspec', () async {
    writePubspec('pkg_a', 'name: pkg_a\nversion: 1.0.0\n');
    writePubspec('nested/pkg_b', 'name: pkg_b\nversion: 2.0.0\n');

    final packages = await sut(repoRoot: tempDir.path);
    final valid = packages.whereType<ValidLocalPackageInfo>();

    expect(
      valid.map((p) => p.packageIdentity.name),
      containsAll(['pkg_a', 'pkg_b']),
    );
  });

  test(
    'should include a package with no version as valid, not malformed',
    () async {
      writePubspec('pkg_a', 'name: pkg_a\nversion: 1.0.0\n');
      writePubspec('unversioned', 'name: unversioned\npublish_to: none\n');

      final packages = await sut(repoRoot: tempDir.path);

      expect(packages.whereType<MalformedLocalPackageInfo>(), isEmpty);
      expect(
        packages.whereType<ValidLocalPackageInfo>().map(
              (p) => p.packageIdentity.name,
            ),
        containsAll(['pkg_a', 'unversioned']),
      );
      final unversioned = packages
          .whereType<ValidLocalPackageInfo>()
          .firstWhere((p) => p.packageIdentity.name == 'unversioned');
      expect(unversioned.packageIdentity.version, isNull);
    },
  );

  test(
    'should report a package with no name as malformed instead of throwing',
    () async {
      writePubspec('pkg_a', 'name: pkg_a\nversion: 1.0.0\n');
      writePubspec('nameless', 'version: 1.0.0\n');

      final packages = await sut(repoRoot: tempDir.path);

      expect(
        packages.whereType<ValidLocalPackageInfo>().map(
              (p) => p.packageIdentity.name,
            ),
        ['pkg_a'],
      );
      final malformed = packages.whereType<MalformedLocalPackageInfo>();
      expect(malformed, hasLength(1));
      expect(malformed.single.repoRootRelativePath, 'nameless');
    },
  );

  test('should throw PackageFinderException when repoRoot does not exist',
      () async {
    expect(
      () => sut(repoRoot: '${tempDir.path}/missing'),
      throwsA(isA<PackageFinderException>()),
    );
  });
}
