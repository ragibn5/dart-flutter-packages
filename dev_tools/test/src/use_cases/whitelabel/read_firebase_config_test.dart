import 'dart:io';

import 'package:dev_tools/src/models/firebase_flavor_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_firebase_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late ReadFirebaseConfig sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('read_firebase_config');
    sut = const ReadFirebaseConfig();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('reads valid Firebase configuration by flavor', () async {
    File('${tempDir.path}/${ReadWhitelabelConfig.fileName}')
        .writeAsStringSync('''
firebase:
  dev:
    project_id: example-dev
    ios_bundle_id: com.example.app.dev
    android_package_name: com.example.app.dev
''');

    expect(await sut(tempDir.path), {
      'dev': const FirebaseFlavorConfig(
        projectId: 'example-dev',
        iosBundleId: 'com.example.app.dev',
        androidPackageName: 'com.example.app.dev',
      ),
    });
  });

  test('ignores incomplete flavor configuration', () async {
    File('${tempDir.path}/${ReadWhitelabelConfig.fileName}')
        .writeAsStringSync('''
firebase:
  dev:
    project_id: example-dev
''');

    expect(await sut(tempDir.path), isEmpty);
  });
}
