import 'dart:io';

import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late ReadWhitelabelConfig sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('read_whitelabel_config');
    sut = const ReadWhitelabelConfig();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('returns an empty set when config does not exist', () async {
    expect(await sut(tempDir.path), isEmpty);
  });

  test('reads project-relative exclude glob patterns from the project config',
      () async {
    File('${tempDir.path}/${ReadWhitelabelConfig.fileName}')
        .writeAsStringSync('''
exclude:
  - .dart_tool/**
  - android/build/**
''');

    expect(await sut(tempDir.path), ['.dart_tool/**', 'android/build/**']);
  });

  test('returns an empty set for a malformed config', () async {
    File('${tempDir.path}/${ReadWhitelabelConfig.fileName}')
        .writeAsStringSync('exclude: [');

    expect(await sut(tempDir.path), isEmpty);
  });
}
