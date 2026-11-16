import 'dart:io';

import 'package:dev_tools/src/models/firebase_flavor_config.dart';
import 'package:dev_tools/src/models/firebase_output_paths.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/whitelabel_config_exception.dart';
import 'package:test/test.dart';

const _output = '''
  output:
    ios: ios/{flavor}/GoogleService-Info.plist
    android: android/{flavor}/google-services.json
    dart: lib/firebase_options_{flavor}.dart
''';

String _flavorEntry(String flavor) => '''
  $flavor:
    project_id: p-$flavor
    ios_bundle_id: ios.$flavor
    android_package_name: android.$flavor
''';

void main() {
  late Directory project;
  const sut = ReadWhitelabelConfig();

  setUp(() => project = Directory.systemTemp.createTempSync('wl_config'));
  tearDown(() => project.deleteSync(recursive: true));

  void writeConfig(String content) =>
      File('${project.path}/${ReadWhitelabelConfig.fileName}')
          .writeAsStringSync(content);

  Matcher throwsConfigError(String containing) => throwsA(
        isA<WhitelabelConfigException>()
            .having((e) => e.message, 'message', contains(containing)),
      );

  test('callShouldReturnNoSettingsIfThereIsNoConfigFile', () async {
    final config = await sut(project.path);

    expect(config.exclude, isEmpty);
    expect(config.flavors, isEmpty);
  });

  test('callShouldReturnNoSettingsIfTheConfigIsMalformed', () async {
    writeConfig('exclude: [unclosed\n');

    expect((await sut(project.path)).exclude, isEmpty);
  });

  test('callShouldReturnNoSettingsIfTheConfigIsNotAMap', () async {
    writeConfig('- build\n');

    expect((await sut(project.path)).exclude, isEmpty);
  });

  test('callShouldReadExcludeAndFlavorsDroppingEmptyFlavors', () async {
    writeConfig('exclude: [build, .dart_tool/**]\nflavors: [dev, "", prod]\n');

    final config = await sut(project.path);

    expect(config.exclude, ['build', '.dart_tool/**']);
    expect(config.flavors, ['dev', 'prod']);
  });

  test('callShouldReadNoExcludeOrFlavorsIfTheyAreNotLists', () async {
    writeConfig('exclude: build\nflavors: dev\n');

    final config = await sut(project.path);

    expect(config.exclude, isEmpty);
    expect(config.flavors, isEmpty);
  });

  test('callShouldReadTheFirebaseOutputAndEveryFlavorEntry', () async {
    writeConfig('flavors: [dev, prod]\nfirebase:\n$_output'
        '${_flavorEntry('dev')}${_flavorEntry('prod')}');

    final config = await sut(project.path);

    expect(
      config.firebaseOutputPaths,
      const FirebaseOutputPaths(
        ios: 'ios/{flavor}/GoogleService-Info.plist',
        android: 'android/{flavor}/google-services.json',
        dart: 'lib/firebase_options_{flavor}.dart',
      ),
    );
    expect(
      config.firebaseFor('prod'),
      const FirebaseFlavorConfig(
        projectId: 'p-prod',
        iosBundleId: 'ios.prod',
        androidPackageName: 'android.prod',
      ),
    );
  });

  test('callShouldReadASingleDefaultEntryIfThereAreNoFlavors', () async {
    writeConfig('firebase:\n$_output${_flavorEntry('default')}');

    expect((await sut(project.path)).firebaseFor('default').projectId,
        'p-default');
  });

  test('callShouldThrowIfFirebaseIsSetWithoutAnOutput', () async {
    writeConfig('flavors: []\nfirebase:\n${_flavorEntry('default')}');

    expect(() => sut(project.path), throwsConfigError("'firebase.output'"));
  });

  test('callShouldThrowIfAnOutputPathIsMissing', () async {
    writeConfig('firebase:\n  output:\n    ios: a\n    android: b\n'
        '${_flavorEntry('default')}');

    expect(
      () => sut(project.path),
      throwsConfigError("'firebase.output.dart' is missing"),
    );
  });

  test('callShouldThrowIfAFlavorEntryIsMissingAField', () async {
    writeConfig('firebase:\n$_output  default:\n    project_id: p\n'
        '    ios_bundle_id: i\n');

    expect(
      () => sut(project.path),
      throwsConfigError("'firebase.default.android_package_name' is missing"),
    );
  });

  test('callShouldThrowNamingTheMissingAndExtraFlavorsIfEntriesDiffer',
      () async {
    writeConfig('flavors: [dev, prod]\nfirebase:\n$_output'
        '${_flavorEntry('dev')}${_flavorEntry('stage')}');

    expect(
      () => sut(project.path),
      throwsConfigError(
        "entries don't match flavors: [dev, prod] — missing: prod; "
        'unexpected (check for typos or stale flavors): stage.',
      ),
    );
  });

  test('callShouldThrowExpectingADefaultEntryIfThereAreNoFlavors', () async {
    writeConfig('firebase:\n$_output${_flavorEntry('dev')}');

    expect(
      () => sut(project.path),
      throwsConfigError('[] (expected a single "default" entry)'),
    );
  });
}
