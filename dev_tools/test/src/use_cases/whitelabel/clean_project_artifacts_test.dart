import 'dart:io';

import 'package:dev_tools/src/use_cases/whitelabel/clean_project_artifacts.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late CleanProjectArtifacts sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('clean_project_artifacts');
    File('${tempDir.path}/pubspec.yaml').writeAsStringSync('name: test\n');
    sut = CleanProjectArtifacts();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('deletes only paths directly matched by configured globs', () async {
    Directory('${tempDir.path}/build').createSync();
    File('${tempDir.path}/build/cache').writeAsStringSync('cache');
    Directory('${tempDir.path}/android/build').createSync(recursive: true);
    File('${tempDir.path}/android/build/cache').writeAsStringSync('cache');
    File('${tempDir.path}/keep.txt').writeAsStringSync('keep');
    File('${tempDir.path}/dev_tools_whitelabel_config.yaml')
        .writeAsStringSync('''
exclude:
  - build
  - android/build/**
''');

    final removed = await sut(tempDir.path);

    expect(removed, contains('build'));
    expect(removed, contains('android/build/cache'));
    expect(Directory('${tempDir.path}/build').existsSync(), isFalse);
    expect(Directory('${tempDir.path}/android/build').existsSync(), isTrue);
    expect(File('${tempDir.path}/android/build/cache').existsSync(), isFalse);
    expect(File('${tempDir.path}/keep.txt').existsSync(), isTrue);
  });
}
