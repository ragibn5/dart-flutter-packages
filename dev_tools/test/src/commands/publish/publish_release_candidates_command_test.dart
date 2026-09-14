import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/publish/publish_release_candidates_command.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:dev_tools/src/use_cases/publish/publish_release_candidates.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockGetRepoRootPath extends Mock implements GetRepoRootPath {}

class _MockPublishReleaseCandidates extends Mock
    implements PublishReleaseCandidates {}

void main() {
  late _MockGetRepoRootPath getRepoRootPath;
  late _MockPublishReleaseCandidates publishReleaseCandidates;
  late PublishReleaseCandidatesCommand sut;

  setUp(() {
    getRepoRootPath = _MockGetRepoRootPath();
    when(() => getRepoRootPath()).thenAnswer((_) async => '/fake/repo');

    publishReleaseCandidates = _MockPublishReleaseCandidates();
    when(() => publishReleaseCandidates(
          repoRoot: any(named: 'repoRoot'),
          packagePaths: any(named: 'packagePaths'),
          dryRun: any(named: 'dryRun'),
        )).thenAnswer((_) async {});

    sut = PublishReleaseCandidatesCommand(
      getRepoRootPath: getRepoRootPath,
      publishReleaseCandidates: publishReleaseCandidates,
    );
  });

  test('should expose the publish-release-candidates name', () {
    expect(sut.name, PublishReleaseCandidatesCommand.commandName);
  });

  test('should describe publishing eligible release candidates', () {
    expect(sut.description, PublishReleaseCandidatesCommand.commandDescription);
  });

  test('should throw a usage exception when no package is given', () async {
    await expectLater(_run(<String>[], sut), throwsA(isA<UsageException>()));

    verifyNever(() => publishReleaseCandidates(
          repoRoot: any(named: 'repoRoot'),
          packagePaths: any(named: 'packagePaths'),
          dryRun: any(named: 'dryRun'),
        ));
  });

  test('should use the resolved repo root and default dry-run', () async {
    await _run(['--package=pkg_a'], sut);

    verify(
      () => publishReleaseCandidates(
        repoRoot: '/fake/repo',
        packagePaths: ['pkg_a'],
        // ignore: avoid_redundant_argument_values
        dryRun: false,
      ),
    ).called(1);
  });

  test('should forward every supplied package and the dry-run flag', () async {
    await _run(['--package=pkg_a', '--package=pkg_b', '--dry-run'], sut);

    verify(
      () => publishReleaseCandidates(
        repoRoot: '/fake/repo',
        packagePaths: ['pkg_a', 'pkg_b'],
        dryRun: true,
      ),
    ).called(1);
  });
}

Future<void> _run(
  List<String> args,
  PublishReleaseCandidatesCommand command,
) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['publish-release-candidates', ...args]);
}
