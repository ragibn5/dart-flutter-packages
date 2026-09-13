// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/models/release_issue.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/read_package_identity.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/validate_package_path.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/git/has_clean_working_tree.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/publish/build_publish_command.dart';
import 'package:dev_tools/src/use_cases/publish/package_publisher.dart';
import 'package:dev_tools/src/use_cases/publish/publish_failed_exception.dart';
import 'package:dev_tools/src/use_cases/publish/run_publish_flow.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/use_cases/release/release_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/verify_release_completeness.dart';
import 'package:dev_tools/src/use_cases/release/verify_versioned_files.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockValidatePackagePath extends Mock implements ValidatePackagePath {}

class _MockReadPackageIdentity extends Mock implements ReadPackageIdentity {}

class _MockHasCleanWorkingTree extends Mock implements HasCleanWorkingTree {}

class _MockConfirmYesNo extends Mock implements ConfirmYesNo {}

class _MockVerifyReleaseCompleteness extends Mock
    implements VerifyReleaseCompleteness {}

class _MockBuildPublishCommand extends Mock implements BuildPublishCommand {}

class _MockPackageRegistryClient extends Mock
    implements PackageRegistryClient {}

class _MockResolveGitTagFormat extends Mock implements ResolveGitTagFormat {}

class _PublishAttempt {
  final String repoRoot;
  final String pkgPath;
  final PackageIdentity identity;
  final bool dryRun;

  const _PublishAttempt(
    this.repoRoot,
    this.pkgPath,
    this.identity, {
    required this.dryRun,
  });
}

class _FakePublisher implements PackagePublisher {
  final bool failingDryRun;
  final bool failingRealPublish;
  final List<_PublishAttempt> calls = [];

  _FakePublisher({
    this.failingDryRun = false,
    this.failingRealPublish = false,
  });

  @override
  Future<void> call({
    required String repoRoot,
    required String pkgPath,
    required PackageIdentity identity,
    required bool dryRun,
    bool verbose = true,
  }) async {
    calls.add(_PublishAttempt(repoRoot, pkgPath, identity, dryRun: dryRun));
    final failing = dryRun ? failingDryRun : failingRealPublish;
    if (failing) {
      throw PublishFailedException(
        dryRun
            ? 'Error: Dry-run failed. Fix issues before publishing.'
            : 'Error: Publishing failed.',
      );
    }
  }
}

void main() {
  const repoRoot = '/fake/repo';
  const pkgPath = 'pkg';
  const packagePath = '$repoRoot/$pkgPath';
  const continuePrompt = 'Continue despite warnings?';
  const publishPrompt = 'Publish foo@1.0.0?';

  setUpAll(() {
    registerFallbackValue(
      const PackageIdentity(name: 'foo', version: '1.0.0'),
    );
    registerFallbackValue(const PublishedPackageInfo());
    registerFallbackValue(const <String, VersionedFileCheck>{});
  });

  late _MockValidatePackagePath validatePackagePath;
  late _MockReadPackageIdentity readPackageIdentity;
  late _MockHasCleanWorkingTree hasCleanWorkingTree;
  late _MockConfirmYesNo confirmYesNo;
  late _MockVerifyReleaseCompleteness verifyReleaseCompleteness;
  late _MockBuildPublishCommand buildPublishCommand;
  late _MockPackageRegistryClient packageRegistryClient;
  late _MockResolveGitTagFormat resolveGitTagFormat;

  late _FakePublisher publisher;
  late RunPublishFlow sut;

  RunPublishFlow buildSut() => RunPublishFlow(
        validatePackagePath: validatePackagePath,
        readPackageIdentity: readPackageIdentity,
        hasCleanWorkingTree: hasCleanWorkingTree,
        confirmYesNo: confirmYesNo,
        verifyReleaseCompleteness: verifyReleaseCompleteness,
        buildPublishCommand: buildPublishCommand,
        packageRegistryClient: packageRegistryClient,
        gitTagFormat: GetTagFormat(resolveGitTagFormat),
        publisher: publisher,
      );

  setUp(() {
    validatePackagePath = _MockValidatePackagePath();
    readPackageIdentity = _MockReadPackageIdentity();
    hasCleanWorkingTree = _MockHasCleanWorkingTree();
    confirmYesNo = _MockConfirmYesNo();
    verifyReleaseCompleteness = _MockVerifyReleaseCompleteness();
    buildPublishCommand = _MockBuildPublishCommand();
    packageRegistryClient = _MockPackageRegistryClient();
    resolveGitTagFormat = _MockResolveGitTagFormat();
    when(() => resolveGitTagFormat()).thenReturn('{name}-{version}');
    publisher = _FakePublisher();

    when(() => validatePackagePath(any())).thenReturn(null);
    when(() => readPackageIdentity(any())).thenAnswer(
      (_) async => const PackageIdentity(name: 'foo', version: '1.0.0'),
    );
    when(() => buildPublishCommand(any())).thenAnswer(
      (_) async => const PublishTooling('fvm dart'),
    );
    when(() => packageRegistryClient(any())).thenAnswer(
      (_) async => const PublishedPackageInfo(),
    );
    when(() => verifyReleaseCompleteness(
          any(),
          publishedPackageInfo: any(named: 'publishedPackageInfo'),
          checks: any(named: 'checks'),
        )).thenAnswer((_) async => const <ReleaseIssue>[]);
    when(() => hasCleanWorkingTree(any())).thenAnswer((_) async => true);
    when(() => confirmYesNo(any())).thenAnswer((_) async => true);

    sut = buildSut();
  });

  test(
    'should throw ReleaseValidationException when the release is incomplete',
    () async {
      when(() => verifyReleaseCompleteness(
            any(),
            publishedPackageInfo: any(named: 'publishedPackageInfo'),
            checks: any(named: 'checks'),
          )).thenAnswer(
        (_) async => const [
          ReleaseIssue('Error: Release is incomplete for foo@1.0.0.'),
        ],
      );

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath),
        throwsA(isA<ReleaseValidationException>()),
      );
      expect(publisher.calls, isEmpty);
    },
  );

  test(
    'should throw PackageRegistryLookupException when the registry cannot '
    'be reached',
    () async {
      when(() => packageRegistryClient(any())).thenThrow(
        const PackageRegistryLookupException('connection timeout'),
      );

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath),
        throwsA(isA<PackageRegistryLookupException>()),
      );
      expect(publisher.calls, isEmpty);
    },
  );

  test(
    'should cancel on the single confirmation when there is no scoped '
    'version and the user declines',
    () async {
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => const PublishTooling('dart'));
      when(() => confirmYesNo(any(that: equals(continuePrompt))))
          .thenAnswer((_) async => false);

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath),
        completes,
      );

      expect(publisher.calls, isEmpty);
    },
  );

  test(
    'should proceed with the system-wide toolchain when the user confirms',
    () async {
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => const PublishTooling('dart'));
      when(() => confirmYesNo(any(that: equals(publishPrompt))))
          .thenAnswer((_) async => true);

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath, dryRunOnly: false),
        completes,
      );

      expect(publisher.calls.map((call) => call.dryRun), <bool>[false]);
    },
  );

  test(
    'should cancel when the working tree is dirty and the user declines',
    () async {
      when(() => hasCleanWorkingTree(any())).thenAnswer((_) async => false);
      when(() => confirmYesNo(any(that: equals(continuePrompt))))
          .thenAnswer((_) async => false);

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath),
        completes,
      );

      expect(publisher.calls, isEmpty);
    },
  );

  test(
    'should continue when the working tree is dirty and the user confirms',
    () async {
      when(() => hasCleanWorkingTree(any())).thenAnswer((_) async => false);
      when(() => confirmYesNo(any(that: equals(continuePrompt))))
          .thenAnswer((_) async => true);
      when(() => confirmYesNo(any(that: equals(publishPrompt))))
          .thenAnswer((_) async => true);

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath, dryRunOnly: false),
        completes,
      );

      expect(publisher.calls.map((call) => call.dryRun), <bool>[false]);
    },
  );

  test('should skip both confirmation prompts when interactive is false',
      () async {
    when(() => hasCleanWorkingTree(any())).thenAnswer((_) async => false);
    when(() => buildPublishCommand(any()))
        .thenAnswer((_) async => const PublishTooling('dart'));

    await expectLater(
      sut(
        repoRoot: repoRoot,
        pkgPath: pkgPath,
        dryRunOnly: false,
        interactive: false,
      ),
      completes,
    );

    verifyNever(() => confirmYesNo(any()));
    expect(publisher.calls.map((call) => call.dryRun), <bool>[false]);
  });

  test(
    'should stop after the dry run when interactive is false and '
    'dryRunOnly is left at its default',
    () async {
      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath, interactive: false),
        completes,
      );

      verifyNever(() => confirmYesNo(any()));
      expect(publisher.calls.map((call) => call.dryRun), <bool>[true]);
    },
  );

  test('should throw PublishFailedException when the dry-run publish fails',
      () async {
    publisher = _FakePublisher(failingDryRun: true);
    sut = buildSut();

    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath),
      throwsA(isA<PublishFailedException>()),
    );
    expect(publisher.calls.map((call) => call.dryRun), <bool>[true]);
  });

  test('should skip the actual publish when dryRunOnly is true', () async {
    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath, dryRunOnly: true),
      completes,
    );

    expect(publisher.calls.map((call) => call.dryRun), <bool>[true]);
  });

  test('should cancel when the user declines the final publish prompt',
      () async {
    when(() => confirmYesNo(any(that: equals(publishPrompt))))
        .thenAnswer((_) async => false);

    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath, dryRunOnly: false),
      completes,
    );

    expect(publisher.calls, isEmpty);
  });

  test('should publish successfully end to end', () async {
    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath, dryRunOnly: false),
      completes,
    );

    expect(publisher.calls.map((call) => call.dryRun), <bool>[false]);
    verify(() => verifyReleaseCompleteness(
          packagePath,
          publishedPackageInfo: any(named: 'publishedPackageInfo'),
          checks: any(named: 'checks'),
        )).called(1);
    verify(() => confirmYesNo(publishPrompt)).called(1);
  });

  test('should throw PublishFailedException when the actual publish fails',
      () async {
    publisher = _FakePublisher(failingRealPublish: true);
    sut = buildSut();

    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath, dryRunOnly: false),
      throwsA(isA<PublishFailedException>()),
    );
    expect(publisher.calls.map((call) => call.dryRun), <bool>[false]);
  });

  test(
    'should publish via the default runner using the resolved tooling prefix',
    () async {
      final tempDir =
          Directory.systemTemp.createTempSync('run_publish_flow_default');
      Directory('${tempDir.path}/pkg').createSync(recursive: true);
      final logFile = '${tempDir.path}/args.log';
      final script = _executableScript(
        tempDir,
        exitCode: 0,
        logFile: logFile,
      );
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => PublishTooling(script));
      addTearDown(() {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      });

      sut = RunPublishFlow(
        validatePackagePath: validatePackagePath,
        readPackageIdentity: readPackageIdentity,
        hasCleanWorkingTree: hasCleanWorkingTree,
        confirmYesNo: confirmYesNo,
        verifyReleaseCompleteness: verifyReleaseCompleteness,
        buildPublishCommand: buildPublishCommand,
        packageRegistryClient: packageRegistryClient,
        gitTagFormat: GetTagFormat(resolveGitTagFormat),
        // The default PackagePublisher (PubPublish) resolves its own
        // tooling independently of RunPublishFlow's; it must share the
        // same mocked buildPublishCommand so it invokes the fake script
        // too, instead of trying to resolve a real dart/flutter toolchain.
        publisher: PubPublish(buildPublishCommand: buildPublishCommand),
      );

      await expectLater(
        sut(repoRoot: tempDir.path, pkgPath: 'pkg', dryRunOnly: false),
        completes,
      );

      final lines = File(logFile).readAsStringSync().trim().split('\n');
      expect(lines, <String>['pub publish --force']);
    },
  );

  test('should throw PublishFailedException when the default runner fails',
      () async {
    final tempDir =
        Directory.systemTemp.createTempSync('run_publish_flow_default_fail');
    Directory('${tempDir.path}/pkg').createSync(recursive: true);
    final logFile = '${tempDir.path}/args.log';
    final script = _executableScript(
      tempDir,
      exitCode: 1,
      logFile: logFile,
    );
    when(() => buildPublishCommand(any()))
        .thenAnswer((_) async => PublishTooling(script));
    addTearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    sut = RunPublishFlow(
      validatePackagePath: validatePackagePath,
      readPackageIdentity: readPackageIdentity,
      hasCleanWorkingTree: hasCleanWorkingTree,
      confirmYesNo: confirmYesNo,
      verifyReleaseCompleteness: verifyReleaseCompleteness,
      buildPublishCommand: buildPublishCommand,
      packageRegistryClient: packageRegistryClient,
      gitTagFormat: GetTagFormat(resolveGitTagFormat),
      publisher: PubPublish(buildPublishCommand: buildPublishCommand),
    );

    await expectLater(
      sut(repoRoot: tempDir.path, pkgPath: 'pkg'),
      throwsA(isA<PublishFailedException>()),
    );

    final lines = File(logFile).readAsStringSync().trim().split('\n');
    expect(lines, <String>['pub publish --dry-run']);
  });
}

String _executableScript(
  Directory dir, {
  required int exitCode,
  required String logFile,
}) {
  final script = File('${dir.path}/cmd.sh')
    ..writeAsStringSync(
      '#!/bin/sh\nprintf "%s\\n" "\$*" >> "$logFile"\nexit $exitCode\n',
    );
  Process.runSync('chmod', ['+x', script.path]);
  return script.path;
}
