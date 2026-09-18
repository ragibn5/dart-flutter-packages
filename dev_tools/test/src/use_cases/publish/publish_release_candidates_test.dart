import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/resolve_local_packages.dart';
import 'package:dev_tools/src/use_cases/git/create_and_push_tag.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/publish/publish_batch_exception.dart';
import 'package:dev_tools/src/use_cases/publish/publish_failed_exception.dart';
import 'package:dev_tools/src/use_cases/publish/publish_release_candidates.dart';
import 'package:dev_tools/src/use_cases/publish/run_publish_flow.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockResolveLocalPackages extends Mock implements ResolveLocalPackages {}

class _MockPackageRegistryClient extends Mock
    implements PackageRegistryClient {}

class _MockRunPublishFlow extends Mock implements RunPublishFlow {}

class _MockCreateAndPushTag extends Mock implements CreateAndPushTag {}

class _MockResolveGitTagFormat extends Mock implements ResolveGitTagFormat {}

void main() {
  const repoRoot = '/fake/repo';
  const notYetPublished = PublishedPackageInfo(versions: ['0.9.0']);

  late _MockResolveLocalPackages resolveLocalPackages;
  late _MockPackageRegistryClient packageRegistryClient;
  late _MockRunPublishFlow runPublishFlow;
  late _MockCreateAndPushTag createAndPushTag;
  late _MockResolveGitTagFormat resolveGitTagFormat;
  late PublishReleaseCandidates sut;

  ValidLocalPackageInfo pkg(
    String path,
    String name, {
    bool isPublishable = true,
  }) =>
      ValidLocalPackageInfo(
        repoRootRelativePath: path,
        packageIdentity: PackageIdentity(
          name: name,
          version: isPublishable ? '1.0.0' : null,
          isPublishable: isPublishable,
        ),
      );

  void resolvesTo(List<ValidLocalPackageInfo> packages) {
    when(() => resolveLocalPackages(
          repoRoot: any(named: 'repoRoot'),
          packagePaths: any(named: 'packagePaths'),
        )).thenAnswer((_) async => packages);
  }

  Future<void> run({
    List<String> packagePaths = const ['pkg_a'],
    bool dryRun = false,
  }) =>
      sut(repoRoot: repoRoot, packagePaths: packagePaths, dryRun: dryRun);

  setUp(() {
    resolveLocalPackages = _MockResolveLocalPackages();
    resolvesTo([pkg('pkg_a', 'pkg_a')]);

    packageRegistryClient = _MockPackageRegistryClient();
    when(() => packageRegistryClient(any()))
        .thenAnswer((_) async => notYetPublished);

    runPublishFlow = _MockRunPublishFlow();
    when(() => runPublishFlow(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: any(named: 'pkgPath'),
          interactive: any(named: 'interactive'),
          dryRunOnly: any(named: 'dryRunOnly'),
        )).thenAnswer((_) async {});

    createAndPushTag = _MockCreateAndPushTag();
    when(() => createAndPushTag(any(), repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async {});

    resolveGitTagFormat = _MockResolveGitTagFormat();
    when(() => resolveGitTagFormat()).thenReturn('{name}-{version}');

    sut = PublishReleaseCandidates(
      logger: _FakeLogger(),
      resolveLocalPackages: resolveLocalPackages,
      packageRegistryClient: packageRegistryClient,
      runPublishFlow: runPublishFlow,
      createAndPushTag: createAndPushTag,
      gitTagFormat: GetTagFormat(resolveGitTagFormat),
    );
  });

  test('should resolve the given package paths under the repo root', () async {
    await run(packagePaths: ['pkg_a', 'pkg_b']);

    verify(() => resolveLocalPackages(
          repoRoot: repoRoot,
          packagePaths: ['pkg_a', 'pkg_b'],
        )).called(1);
  });

  test('should complete without publishing when given no packages', () async {
    resolvesTo(const []);

    await expectLater(run(packagePaths: const []), completes);

    verifyNever(() => runPublishFlow(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: any(named: 'pkgPath'),
          interactive: any(named: 'interactive'),
          dryRunOnly: any(named: 'dryRunOnly'),
        ));
  });

  test('should skip a package that is not publishable', () async {
    resolvesTo([pkg('pkg_a', 'pkg_a', isPublishable: false)]);

    await expectLater(run(), completes);

    verifyNever(() => runPublishFlow(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: any(named: 'pkgPath'),
          interactive: any(named: 'interactive'),
          dryRunOnly: any(named: 'dryRunOnly'),
        ));
  });

  test('should skip a package whose current version is already published',
      () async {
    when(() => packageRegistryClient(any()))
        .thenAnswer((_) async => const PublishedPackageInfo(
              versions: ['1.0.0'],
            ));

    await expectLater(run(), completes);

    verifyNever(() => runPublishFlow(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: any(named: 'pkgPath'),
          interactive: any(named: 'interactive'),
          dryRunOnly: any(named: 'dryRunOnly'),
        ));
  });

  test('should publish every eligible candidate non-interactively', () async {
    resolvesTo([pkg('pkg_a', 'pkg_a'), pkg('pkg_b', 'pkg_b')]);

    await run(packagePaths: ['pkg_a', 'pkg_b']);

    verify(() => runPublishFlow(
          repoRoot: repoRoot,
          pkgPath: 'pkg_a',
          interactive: false,
          dryRunOnly: false,
        )).called(1);
    verify(() => runPublishFlow(
          repoRoot: repoRoot,
          pkgPath: 'pkg_b',
          interactive: false,
          dryRunOnly: false,
        )).called(1);
  });

  test('should tag every candidate that publishes successfully', () async {
    await run();

    verify(() => createAndPushTag('pkg_a-1.0.0', repoRoot: repoRoot)).called(1);
  });

  test(
      'should follow the dryRun flag rather than publishing for real when '
      'set', () async {
    await run(dryRun: true);

    verify(() => runPublishFlow(
          repoRoot: repoRoot,
          pkgPath: 'pkg_a',
          // ignore: avoid_redundant_argument_values
          interactive: false,
          // ignore: avoid_redundant_argument_values
          dryRunOnly: true,
        )).called(1);
  });

  test('should not create or push a tag on a dry run', () async {
    await run(dryRun: true);

    verifyNever(
      () => createAndPushTag(any(), repoRoot: any(named: 'repoRoot')),
    );
  });

  test('should attempt every candidate even when one fails to publish',
      () async {
    resolvesTo([pkg('pkg_a', 'pkg_a'), pkg('pkg_b', 'pkg_b')]);
    when(() => runPublishFlow(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: 'pkg_a',
          interactive: any(named: 'interactive'),
          dryRunOnly: any(named: 'dryRunOnly'),
        )).thenThrow(const PublishFailedException('Publishing failed.'));

    await expectLater(
      run(packagePaths: ['pkg_a', 'pkg_b']),
      throwsA(isA<PublishBatchException>()),
    );

    verify(() => runPublishFlow(
          repoRoot: repoRoot,
          pkgPath: 'pkg_b',
          interactive: false,
          dryRunOnly: false,
        )).called(1);
    verify(() => createAndPushTag('pkg_b-1.0.0', repoRoot: repoRoot)).called(1);
    verifyNever(() => createAndPushTag('pkg_a-1.0.0', repoRoot: repoRoot));
  });

  test('should propagate PackageNotFoundException from resolution', () async {
    when(() => resolveLocalPackages(
          repoRoot: any(named: 'repoRoot'),
          packagePaths: any(named: 'packagePaths'),
        )).thenThrow(const PackageNotFoundException('nope: not found.'));

    await expectLater(run(), throwsA(isA<PackageNotFoundException>()));
  });

  test('should not throw when every candidate publishes successfully',
      () async {
    await expectLater(run(), completes);
  });
}

class _FakeLogger extends Logger {
  @override
  void log(LogLevel level, String message, {StackTrace? stackTrace}) {}
}
