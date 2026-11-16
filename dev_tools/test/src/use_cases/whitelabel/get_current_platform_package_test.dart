import 'dart:io';

import 'package:dev_tools/src/use_cases/whitelabel/get_current_platform_package.dart';
import 'package:test/test.dart';

void main() {
  late Directory project;
  const sut = GetCurrentPlatformPackage();

  setUp(() => project = Directory.systemTemp.createTempSync('platform_pkg'));
  tearDown(() => project.deleteSync(recursive: true));

  void writeGradle(String content) =>
      (File('${project.path}/android/app/build.gradle.kts')
            ..createSync(recursive: true))
          .writeAsStringSync(content);

  test('callShouldReturnTheApplicationIdIfTheGradleFileSetsIt', () async {
    writeGradle('android {\n  defaultConfig {\n'
        '    applicationId = "com.example.app"\n  }\n}\n');

    expect(await sut(project.path), 'com.example.app');
  });

  test('callShouldReturnEmptyIfThereIsNoGradleFile', () async {
    expect(await sut(project.path), '');
  });

  test('callShouldReturnEmptyIfTheGradleFileSetsNoApplicationId', () async {
    writeGradle('android {}\n');

    expect(await sut(project.path), '');
  });
}
