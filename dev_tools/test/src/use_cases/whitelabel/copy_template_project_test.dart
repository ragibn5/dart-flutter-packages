import 'dart:io';

import 'package:dev_tools/src/use_cases/whitelabel/copy_template_project.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late Directory template;
  late CopyTemplateProject sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('copy_template_project_test');
    template = Directory('${tempDir.path}/template')..createSync();
    File('${template.path}/pubspec.yaml').writeAsStringSync('name: template\n');
    File('${template.path}/readme.md').writeAsStringSync('hello');
    Directory('${template.path}/lib').createSync();
    File('${template.path}/lib/main.dart').writeAsStringSync('void main() {}');
    Directory('${template.path}/.git').createSync();
    File('${template.path}/.git/config').writeAsStringSync('private');
    sut = CopyTemplateProject();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('copies template content but not its git metadata', () async {
    final destination = '${tempDir.path}/new-project';

    final result = await sut(template: template.path, destination: destination);

    expect(result, Directory(destination).absolute.path);
    expect(File('$destination/readme.md').readAsStringSync(), 'hello');
    expect(File('$destination/lib/main.dart').existsSync(), isTrue);
    expect(Directory('$destination/.git').existsSync(), isFalse);
  });

  test('applies project-relative exclude globs without expanding them',
      () async {
    final destination = '${tempDir.path}/new-project';
    Directory('${template.path}/android/build').createSync(recursive: true);
    File('${template.path}/android/build/cache.txt').writeAsStringSync('cache');
    Directory('${template.path}/android/app').createSync(recursive: true);
    File('${template.path}/android/app/keep.txt').writeAsStringSync('keep');
    File('${template.path}/dev_tools_whitelabel_config.yaml')
        .writeAsStringSync('''
exclude:
  - android/build/**
  - readme.md
''');

    await sut(
      template: template.path,
      destination: destination,
    );

    expect(File('$destination/pubspec.yaml').existsSync(), isTrue);
    expect(File('$destination/readme.md').existsSync(), isFalse);
    expect(File('$destination/lib/main.dart').existsSync(), isTrue);
    expect(Directory('$destination/android/build').existsSync(), isTrue);
    expect(File('$destination/android/build/cache.txt').existsSync(), isFalse);
    expect(File('$destination/android/app/keep.txt').existsSync(), isTrue);
    expect(Directory('$destination/.git').existsSync(), isFalse);
  });

  test('rejects a destination within the template', () async {
    expect(
      () => sut(template: template.path, destination: '${template.path}/copy'),
      throwsA(isA<WhitelabelProjectException>()),
    );
  });

  test('rejects an existing destination by default', () async {
    final destination = Directory('${tempDir.path}/existing')..createSync();

    expect(
      () => sut(template: template.path, destination: destination.path),
      throwsA(isA<WhitelabelProjectException>()),
    );
  });

  test('uses an existing empty destination only with force enabled', () async {
    final destination = Directory('${tempDir.path}/empty')..createSync();

    await sut(
      template: template.path,
      destination: destination.path,
      allowExistingEmptyDirectory: true,
    );

    expect(File('${destination.path}/pubspec.yaml').existsSync(), isTrue);
  });
}
