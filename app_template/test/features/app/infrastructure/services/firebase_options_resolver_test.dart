import 'package:app_template/features/app/infrastructure/config/firebase/firebase_options_dev.dart'
    as dev_firebase_options;
import 'package:app_template/features/app/infrastructure/config/firebase/firebase_options_exp.dart'
    as exp_firebase_options;
import 'package:app_template/features/app/infrastructure/config/firebase/firebase_options_prod.dart'
    as prod_firebase_options;
import 'package:app_template/features/app/infrastructure/config/firebase/firebase_options_stage.dart'
    as stage_firebase_options;
import 'package:app_template/features/app/infrastructure/services/firebase_options_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FirebaseOptionsResolver sut;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    sut = const FirebaseOptionsResolver();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('getForFlavor returns dev FirebaseOptions for AppFlavor.DEV', () {
    expect(
      sut.getForFlavor(.DEV),
      dev_firebase_options.DefaultFirebaseOptions.android,
    );
  });

  test('getForFlavor returns exp FirebaseOptions for AppFlavor.EXP', () {
    expect(
      sut.getForFlavor(.EXP),
      exp_firebase_options.DefaultFirebaseOptions.android,
    );
  });

  test('getForFlavor returns stage FirebaseOptions for AppFlavor.STAGE', () {
    expect(
      sut.getForFlavor(.STAGE),
      stage_firebase_options.DefaultFirebaseOptions.android,
    );
  });

  test('getForFlavor returns prod FirebaseOptions for AppFlavor.PROD', () {
    expect(
      sut.getForFlavor(.PROD),
      prod_firebase_options.DefaultFirebaseOptions.android,
    );
  });
}
