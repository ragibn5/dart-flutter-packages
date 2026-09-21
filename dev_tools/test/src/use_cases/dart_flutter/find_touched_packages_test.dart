import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_touched_packages.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindPackages extends Mock implements FindPackages {}

class _MockDetectChangesInFolder extends Mock
    implements DetectChangesInFolder {}

void main() {
  const repoRoot = '/fake/repo';

  late _MockFindPackages findPackages;
  late _MockDetectChangesInFolder detectChangesInFolder;
  late FindTouchedPackages sut;

  ValidLocalPackageInfo pkg(String path, String name) => ValidLocalPackageInfo(
        repoRootRelativePath: path,
        packageIdentity: PackageIdentity(name: name, version: '1.0.0'),
      );

  Future<List<ValidLocalPackageInfo>> run({
    String fromRef = 'HEAD^',
    String toRef = 'HEAD',
    List<String> skipPaths = const [],
  }) =>
      sut(
        repoRoot: repoRoot,
        fromRef: fromRef,
        toRef: toRef,
        skipPaths: skipPaths,
      );

  setUp(() {
    findPackages = _MockFindPackages();
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => const <PackageInfo>[]);

    detectChangesInFolder = _MockDetectChangesInFolder();
    when(() => detectChangesInFolder(
          baseRef: any(named: 'baseRef'),
          compareRef: any(named: 'compareRef'),
        )).thenAnswer((_) async => const <String>[]);

    sut = FindTouchedPackages(
      findPackages: findPackages,
      detectChangesInFolder: detectChangesInFolder,
    );
  });

  test('should diff with fromRef as the base and toRef as the compare ref',
      () async {
    await run(fromRef: 'main~1', toRef: 'main');

    verify(() => detectChangesInFolder(
          baseRef: 'main~1',
          compareRef: 'main',
        )).called(1);
  });

  test('should return only packages touched by the diff', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot'))).thenAnswer(
        (_) async => [pkg('pkg_a', 'pkg_a'), pkg('pkg_b', 'pkg_b')]);
    when(() => detectChangesInFolder(
          baseRef: any(named: 'baseRef'),
          compareRef: any(named: 'compareRef'),
        )).thenAnswer((_) async => ['pkg_a/lib/pkg_a.dart']);

    final result = await run();

    expect(result.map((p) => p.repoRootRelativePath), ['pkg_a']);
  });

  test('should return an empty list when nothing was touched', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => [pkg('pkg_a', 'pkg_a')]);
    when(() => detectChangesInFolder(
          baseRef: any(named: 'baseRef'),
          compareRef: any(named: 'compareRef'),
        )).thenAnswer((_) async => ['docs/readme.md']);

    final result = await run();

    expect(result, isEmpty);
  });

  test('should skip a package under a skipped path prefix', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot'))).thenAnswer(
      (_) async => [
        pkg('app_template', 'app_template'),
        pkg('app_template/nested', 'nested'),
        pkg('pkg_a', 'pkg_a'),
      ],
    );
    when(() => detectChangesInFolder(
          baseRef: any(named: 'baseRef'),
          compareRef: any(named: 'compareRef'),
        )).thenAnswer((_) async => [
          'app_template/lib/app_template.dart',
          'app_template/nested/lib/nested.dart',
          'pkg_a/lib/pkg_a.dart',
        ]);

    final result = await run(skipPaths: ['app_template']);

    expect(result.map((p) => p.repoRootRelativePath), ['pkg_a']);
  });
}
