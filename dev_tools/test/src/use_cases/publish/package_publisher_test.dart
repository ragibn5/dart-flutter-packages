// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/use_cases/publish/build_publish_command.dart';
import 'package:dev_tools/src/use_cases/publish/package_publisher.dart';
import 'package:dev_tools/src/use_cases/publish/publish_failed_exception.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockBuildPublishCommand extends Mock implements BuildPublishCommand {}

class _FakeLogger implements Logger {
  final List<String> infoMessages = [];
  final List<String> warnMessages = [];

  @override
  void info(String message) => infoMessages.add(message);

  @override
  void warn(String message) => warnMessages.add(message);

  @override
  void error(String message, {StackTrace? stackTrace}) {}
}

void main() {
  const identity = PackageIdentity(name: 'foo', version: '1.0.0');

  late _MockBuildPublishCommand buildPublishCommand;
  late _FakeLogger logger;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(identity);
  });

  setUp(() {
    buildPublishCommand = _MockBuildPublishCommand();
    logger = _FakeLogger();
    tempDir = Directory.systemTemp.createTempSync('package_publisher_test');
    Directory('${tempDir.path}/pkg').createSync(recursive: true);
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  PubPublish buildSut() => PubPublish(
        logger: logger,
        buildPublishCommand: buildPublishCommand,
      );

  test(
    'logs the working directory before running the publish command',
    () async {
      final script = _executableScript(tempDir, exitCode: 0);
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => PublishTooling(script));

      await buildSut()(
        repoRoot: tempDir.path,
        pkgPath: 'pkg',
        identity: identity,
        dryRun: true,
      );

      expect(
        logger.infoMessages,
        contains(
          'Running dry-run publish for foo in ${tempDir.path}/pkg',
        ),
      );
    },
  );

  test(
    'logs a real-publish message (no dry-run prefix) when publishing for real',
    () async {
      final script = _executableScript(tempDir, exitCode: 0);
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => PublishTooling(script));

      await buildSut()(
        repoRoot: tempDir.path,
        pkgPath: 'pkg',
        identity: identity,
        dryRun: false,
      );

      expect(
        logger.infoMessages,
        contains('Running publish for foo in ${tempDir.path}/pkg'),
      );
    },
  );

  test('passes --dry-run when dryRun is true', () async {
    final logFile = '${tempDir.path}/args.log';
    final script = _executableScript(tempDir, exitCode: 0, logFile: logFile);
    when(() => buildPublishCommand(any()))
        .thenAnswer((_) async => PublishTooling(script));

    await buildSut()(
      repoRoot: tempDir.path,
      pkgPath: 'pkg',
      identity: identity,
      dryRun: true,
    );

    expect(File(logFile).readAsStringSync().trim(), 'pub publish --dry-run');
  });

  test('passes --force when dryRun is false', () async {
    final logFile = '${tempDir.path}/args.log';
    final script = _executableScript(tempDir, exitCode: 0, logFile: logFile);
    when(() => buildPublishCommand(any()))
        .thenAnswer((_) async => PublishTooling(script));

    await buildSut()(
      repoRoot: tempDir.path,
      pkgPath: 'pkg',
      identity: identity,
      dryRun: false,
    );

    expect(File(logFile).readAsStringSync().trim(), 'pub publish --force');
  });

  test(
    'throws a dry-run PublishFailedException when the dry run fails',
    () async {
      final script = _executableScript(tempDir, exitCode: 1);
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => PublishTooling(script));

      await expectLater(
        buildSut()(
          repoRoot: tempDir.path,
          pkgPath: 'pkg',
          identity: identity,
          dryRun: true,
        ),
        throwsA(
          isA<PublishFailedException>().having(
            (e) => e.message,
            'message',
            'Error: Dry-run failed. Fix issues before publishing.',
          ),
        ),
      );
    },
  );

  test(
    'throws a publish PublishFailedException when the real publish fails',
    () async {
      final script = _executableScript(tempDir, exitCode: 1);
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => PublishTooling(script));

      await expectLater(
        buildSut()(
          repoRoot: tempDir.path,
          pkgPath: 'pkg',
          identity: identity,
          dryRun: false,
        ),
        throwsA(
          isA<PublishFailedException>().having(
            (e) => e.message,
            'message',
            'Error: Publishing failed.',
          ),
        ),
      );
    },
  );

  test(
    'surfaces the captured output via the logger when a silent (non-verbose) '
    'run fails',
    () async {
      final script = _executableScript(
        tempDir,
        exitCode: 1,
        stdout: 'captured stdout',
        stderr: 'captured stderr',
      );
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => PublishTooling(script));

      await expectLater(
        buildSut()(
          repoRoot: tempDir.path,
          pkgPath: 'pkg',
          identity: identity,
          dryRun: true,
          verbose: false,
        ),
        throwsA(isA<PublishFailedException>()),
      );

      expect(logger.infoMessages, contains(contains('captured stdout')));
      expect(logger.warnMessages, contains(contains('captured stderr')));
    },
  );

  test(
    'stays quiet (besides the working-directory log) on a successful '
    'silent (non-verbose) run',
    () async {
      final script = _executableScript(
        tempDir,
        exitCode: 0,
        stdout: 'captured stdout',
      );
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => PublishTooling(script));

      await buildSut()(
        repoRoot: tempDir.path,
        pkgPath: 'pkg',
        identity: identity,
        dryRun: true,
        verbose: false,
      );

      expect(
        logger.infoMessages,
        isNot(contains(contains('captured stdout'))),
      );
    },
  );
}

String _executableScript(
  Directory dir, {
  required int exitCode,
  String? logFile,
  String? stdout,
  String? stderr,
}) {
  final buffer = StringBuffer('#!/bin/sh\n');
  if (logFile != null) {
    buffer.writeln('printf "%s\\n" "\$*" >> "$logFile"');
  }
  if (stdout != null) {
    buffer.writeln('printf "%s\\n" "$stdout"');
  }
  if (stderr != null) {
    buffer.writeln('printf "%s\\n" "$stderr" >&2');
  }
  buffer.writeln('exit $exitCode');
  final script = File('${dir.path}/cmd.sh')
    ..writeAsStringSync(buffer.toString());
  Process.runSync('chmod', ['+x', script.path]);
  return script.path;
}
