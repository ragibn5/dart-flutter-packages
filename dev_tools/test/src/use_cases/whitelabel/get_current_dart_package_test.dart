import 'dart:io';

import 'package:dev_tools/src/use_cases/whitelabel/get_current_dart_package.dart';
import 'package:test/test.dart';

void main() {
  late Directory project;
  const sut = GetCurrentDartPackage();

  setUp(() => project = Directory.systemTemp.createTempSync('dart_package'));
  tearDown(() => project.deleteSync(recursive: true));

  void writePubspec(String content) =>
      File('${project.path}/pubspec.yaml').writeAsStringSync(content);

  test('callShouldReturnThePubspecNameIfItIsSet', () async {
    writePubspec('name: my_app\n');

    expect(await sut(project.path), 'my_app');
  });

  test('callShouldReturnEmptyIfThereIsNoPubspec', () async {
    expect(await sut(project.path), '');
  });

  test('callShouldReturnEmptyIfThePubspecIsMalformed', () async {
    writePubspec('name: [unclosed\n');

    expect(await sut(project.path), '');
  });

  test('callShouldReturnEmptyIfThePubspecIsNotAMap', () async {
    writePubspec('- just a list\n');

    expect(await sut(project.path), '');
  });

  test('callShouldReturnEmptyIfTheNameIsNotAString', () async {
    writePubspec('name: 42\n');

    expect(await sut(project.path), '');
  });
}
