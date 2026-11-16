import 'dart:io';

import 'package:dev_tools/src/models/firebase_flavor_config.dart';
import 'package:dev_tools/src/models/firebase_output_paths.dart';
import 'package:dev_tools/src/models/whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/prompts/prompt_with_default.dart';
import 'package:dev_tools/src/use_cases/whitelabel/ensure_firebase_account.dart';
import 'package:dev_tools/src/use_cases/whitelabel/firebase_setup_exception.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/run_firebase_setup.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockReadWhitelabelConfig extends Mock implements ReadWhitelabelConfig {}

class _MockEnsureFirebaseAccount extends Mock
    implements EnsureFirebaseAccount {}

WhitelabelConfig _config(List<String> flavors) => WhitelabelConfig(
      exclude: const [],
      flavors: flavors,
      firebase: {
        for (final flavor in flavors.isEmpty ? ['default'] : flavors)
          flavor: FirebaseFlavorConfig(
            projectId: 'p-$flavor',
            iosBundleId: 'ios.$flavor',
            androidPackageName: 'android.$flavor',
          ),
      },
      firebaseOutputPaths: const FirebaseOutputPaths(
        ios: 'ios/{flavor}/GoogleService-Info.plist',
        android: 'android/{flavor}/google-services.json',
        dart: 'lib/{flavor}/firebase_options.dart',
      ),
    );

void main() {
  late Directory project;
  late _MockReadWhitelabelConfig readWhitelabelConfig;
  late _MockEnsureFirebaseAccount ensureFirebaseAccount;
  late FakeLogger logger;

  setUp(() {
    project = Directory.systemTemp.createTempSync('run_firebase_setup');
    readWhitelabelConfig = _MockReadWhitelabelConfig();
    ensureFirebaseAccount = _MockEnsureFirebaseAccount();
    logger = FakeLogger();
    when(() => ensureFirebaseAccount()).thenAnswer((_) async {});
  });

  tearDown(() => project.deleteSync(recursive: true));

  RunFirebaseSetup sutWith({
    required List<String> flavors,
    required List<String?> answers,
    required FakeRunInteractiveProcess process,
  }) {
    when(() => readWhitelabelConfig(any()))
        .thenAnswer((_) async => _config(flavors));
    final prompter = FakePrompter(answers);
    return RunFirebaseSetup(
      logger: logger,
      readWhitelabelConfig: readWhitelabelConfig,
      promptWithDefault: PromptWithDefault(prompter: prompter),
      confirmYesNo: ConfirmYesNo(prompter: prompter),
      ensureFirebaseAccount: ensureFirebaseAccount,
      runInteractiveProcess: process,
    );
  }

  test('callShouldRunFlutterfireWithTheFlavorsPathsIfConfirmed', () async {
    final process = FakeRunInteractiveProcess();

    await sutWith(
      flavors: ['dev', 'prod'],
      answers: ['', 'ios.custom', '', 'y'],
      process: process,
    )(project.path, 'dev');

    verify(() => ensureFirebaseAccount()).called(1);
    final call = process.calls.single;
    expect(call.executable, 'flutterfire');
    expect(call.arguments, [
      'configure',
      '--project=p-dev',
      '--out=lib/dev/firebase_options.dart',
      '--ios-bundle-id=ios.custom',
      '--ios-out=ios/dev/GoogleService-Info.plist',
      '--android-package-name=android.dev',
      '--android-out=android/dev/google-services.json',
    ]);
    expect(call.workingDirectory, project.path);
    expect(call.inheritStdio, isTrue);
    for (final dir in ['ios/dev', 'android/dev', 'lib/dev']) {
      expect(Directory('${project.path}/$dir').existsSync(), isTrue);
    }
    expect(
      logger.messages.last.$2,
      'Configuration complete for dev environment!',
    );
  });

  test('callShouldAbortWithoutRunningFlutterfireIfNotConfirmed', () async {
    final process = FakeRunInteractiveProcess();

    await sutWith(
      flavors: [],
      answers: ['', '', '', 'n'],
      process: process,
    )(project.path, 'default');

    expect(process.calls, isEmpty);
    expect(logger.messages.last.$2, 'Aborted.');
  });

  test('callShouldThrowIfFlutterfireFails', () async {
    expect(
      sutWith(
        flavors: [],
        answers: ['', '', '', 'y'],
        process: FakeRunInteractiveProcess(exitCode: 1),
      )(project.path, 'default'),
      throwsA(
        isA<FirebaseSetupException>().having(
          (e) => e.message,
          'message',
          'flutterfire configure exited with code 1.',
        ),
      ),
    );
  });

  test('callShouldThrowListingTheFlavorsIfTheFlavorIsUnknown', () async {
    expect(
      sutWith(
        flavors: ['dev', 'prod'],
        answers: [],
        process: FakeRunInteractiveProcess(),
      )(project.path, 'stage'),
      throwsA(
        isA<FirebaseSetupException>().having(
          (e) => e.message,
          'message',
          "Invalid flavor 'stage'. Use one of: dev, prod.",
        ),
      ),
    );
  });

  test('callShouldThrowAskingForDefaultIfAFlavorlessProjectGetsAFlavor',
      () async {
    expect(
      sutWith(
        flavors: [],
        answers: [],
        process: FakeRunInteractiveProcess(),
      )(project.path, 'dev'),
      throwsA(
        isA<FirebaseSetupException>().having(
          (e) => e.message,
          'message',
          "Invalid flavor 'dev'. Use one of: default.",
        ),
      ),
    );
  });
}
