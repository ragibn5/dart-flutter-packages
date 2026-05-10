import 'package:app_template/features/app/infrastructure/config/firebase/firebase_options_dev.dart'
    as dev_firebase_options;
import 'package:app_template/features/app/infrastructure/config/firebase/firebase_options_exp.dart'
    as exp_firebase_options;
import 'package:app_template/features/app/infrastructure/config/firebase/firebase_options_prod.dart'
    as prod_firebase_options;
import 'package:app_template/features/app/infrastructure/config/firebase/firebase_options_stage.dart'
    as stage_firebase_options;
import 'package:app_template/features/app/infrastructure/models/app_flavor.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseOptionsResolver {
  const FirebaseOptionsResolver();

  FirebaseOptions getForFlavor(AppFlavor flavor) {
    return switch (flavor) {
      AppFlavor.DEV =>
        dev_firebase_options.DefaultFirebaseOptions.currentPlatform,
      AppFlavor.EXP =>
        exp_firebase_options.DefaultFirebaseOptions.currentPlatform,
      AppFlavor.STAGE =>
        stage_firebase_options.DefaultFirebaseOptions.currentPlatform,
      AppFlavor.PROD =>
        prod_firebase_options.DefaultFirebaseOptions.currentPlatform,
    };
  }
}
