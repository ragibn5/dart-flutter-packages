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

class StartupConfig {
  final AppFlavor flavor;
  final FirebaseOptions firebaseOptions;

  StartupConfig._(this.flavor, this.firebaseOptions);

  factory StartupConfig.dev() {
    return StartupConfig._(
      AppFlavor.DEV,
      dev_firebase_options.DefaultFirebaseOptions.currentPlatform,
    );
  }

  factory StartupConfig.exp() {
    return StartupConfig._(
      AppFlavor.EXP,
      exp_firebase_options.DefaultFirebaseOptions.currentPlatform,
    );
  }

  factory StartupConfig.stage() {
    return StartupConfig._(
      AppFlavor.STAGE,
      stage_firebase_options.DefaultFirebaseOptions.currentPlatform,
    );
  }

  factory StartupConfig.prod() {
    return StartupConfig._(
      AppFlavor.PROD,
      prod_firebase_options.DefaultFirebaseOptions.currentPlatform,
    );
  }

  StartupConfig copyWith({
    AppFlavor? flavor,
    FirebaseOptions? firebaseOptions,
  }) {
    return StartupConfig._(
      flavor ?? this.flavor,
      firebaseOptions ?? this.firebaseOptions,
    );
  }
}
