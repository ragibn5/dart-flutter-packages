import 'dart:io';

import 'package:dev_tools/src/models/whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/find_replace/replace_text_in_scope.dart';
import 'package:dev_tools/src/use_cases/whitelabel/get_current_platform_package.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/rename_platform_package.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockReplaceTextInScope extends Mock implements ReplaceTextInScope {}

class _MockReadWhitelabelConfig extends Mock implements ReadWhitelabelConfig {}

class _FixedPlatformPackage extends GetCurrentPlatformPackage {
  const _FixedPlatformPackage();

  @override
  Future<String> call(String projectPath) async => 'com.old.app';
}

void main() {
  late Directory project;
  late _MockReplaceTextInScope replaceTextInScope;
  late _MockReadWhitelabelConfig readWhitelabelConfig;

  setUp(() {
    project = Directory.systemTemp.createTempSync('rename_platform');
    replaceTextInScope = _MockReplaceTextInScope();
    readWhitelabelConfig = _MockReadWhitelabelConfig();
    when(
      () => replaceTextInScope(
        srcText: any(named: 'srcText'),
        targetText: any(named: 'targetText'),
        start: any(named: 'start'),
        exclusions: any(named: 'exclusions'),
      ),
    ).thenAnswer((_) async => 1);
    when(() => readWhitelabelConfig(any())).thenAnswer(
      (_) async => const WhitelabelConfig(
        exclude: ['build'],
        flavors: ['dev'],
        firebase: {},
        firebaseOutputPaths: null,
      ),
    );
  });

  tearDown(() => project.deleteSync(recursive: true));

  RenamePlatformPackage sutWith(FakePrompter prompter) => RenamePlatformPackage(
        prompter: prompter,
        getCurrentPlatformPackage: const _FixedPlatformPackage(),
        replaceTextInScope: replaceTextInScope,
        readWhitelabelConfig: readWhitelabelConfig,
      );

  Directory sourceDir(String sourceSet, String language, String package) =>
      Directory(
        '${project.path}/android/app/src/$sourceSet/$language/'
        '${package.replaceAll('.', '/')}',
      );

  test('callShouldReplaceTheCurrentPackageIfTheSourceIsLeftAtItsDefault',
      () async {
    await sutWith(FakePrompter(['', 'com.new.app']))(project.path);

    verify(
      () => replaceTextInScope(
        srcText: 'com.old.app',
        targetText: 'com.new.app',
        start: project.path,
        exclusions: ['.git', 'build'],
      ),
    ).called(1);
  });

  test('callShouldMoveThePackageDirectoriesOfEverySourceSetAndFlavor',
      () async {
    for (final (sourceSet, language) in [
      ('main', 'kotlin'),
      ('dev', 'java'),
      ('testDev', 'kotlin'),
      ('androidTestDev', 'java'),
    ]) {
      File('${sourceDir(sourceSet, language, 'com.old.app').path}/A.kt')
        ..createSync(recursive: true)
        ..writeAsStringSync('package com.old.app');
    }
    final prompter = FakePrompter(['', 'com.new.app']);

    await sutWith(prompter)(project.path);

    for (final (sourceSet, language) in [
      ('main', 'kotlin'),
      ('dev', 'java'),
      ('testDev', 'kotlin'),
      ('androidTestDev', 'java'),
    ]) {
      expect(
          sourceDir(sourceSet, language, 'com.old.app').existsSync(), isFalse);
      expect(
        File('${sourceDir(sourceSet, language, 'com.new.app').path}/A.kt')
            .existsSync(),
        isTrue,
      );
    }
    expect(prompter.output, contains('Moving package directories...'));
    expect(
      prompter.output,
      contains('Platform package name replacement completed'),
    );
  });

  test('callShouldNotReportMovesIfThereAreNoPackageDirectories', () async {
    final prompter = FakePrompter(['', 'com.new.app']);

    await sutWith(prompter)(project.path);

    expect(prompter.output, isNot(contains('Moving package directories')));
  });

  test('callShouldSkipTheRenameIfTheTargetIsEmpty', () async {
    final prompter = FakePrompter(['', '']);

    await sutWith(prompter)(project.path);

    verifyNever(() => readWhitelabelConfig(any()));
    expect(prompter.output, contains('Both package names are required'));
  });
}
