import 'dart:async';

import 'package:app_template/di/provider/dependency_provider.dart';
import 'package:app_template/features/app/infrastructure/models/app_flavor.dart';
import 'package:app_template/features/app/infrastructure/services/app_config_factory.dart';
import 'package:app_template/features/app/infrastructure/services/firebase_options_resolver.dart';
import 'package:app_template/features/app/presentation/bloc/app_bloc.dart';
import 'package:app_template/features/app/presentation/widgets/app_root/app_root.dart';
import 'package:app_template/features/app/presentation/widgets/startup_error/startup_error_page.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/router/app_router.dart';
import 'package:app_template/shared/crashlytics/crashlytics_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> runFlavoredApp({required AppFlavor flavor}) async {
  await runZonedGuarded(
    () async {
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      final platformDispatcher = widgetsBinding.platformDispatcher;

      // Present the splash screen while we do app initialization.
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      try {
        // Set up infra services
        await Firebase.initializeApp(
          options: const FirebaseOptionsResolver().getForFlavor(flavor),
        );

        // Set up dependencies
        await di.initialize(flavor);
      } catch (e, st) {
        // Run the app with fallback error page
        runApp(
          MaterialApp(
            home: StartupErrorPage(
              errorTitle: 'Startup error',
              errorDescription: e.toString(),
              stackTrace: st,
            ),
          ),
        );

        // Remove splash
        FlutterNativeSplash.remove();

        // We really can't do anything else!
        return;
      }

      // Run the app
      runApp(
        BlocProvider(
          create: (context) =>
              di.get<AppBloc>()..add(AppInitializationRequested()),
          child: AppRoot(
            router: di.get<AppRouter>(),
            authDataService: di.get<AuthDataService>(),
            scaffoldMessengerKey: di.get<GlobalKey<ScaffoldMessengerState>>(),
            platformConfig: di.get<AppConfigFactory>().create(
              platformDispatcher,
            ),
          ),
        ),
      );

      // Remove splash - we are in our app!
      FlutterNativeSplash.remove();
    },
    (error, stackTrace) {
      // We are using optional getter, as the dependencies may not
      // be initialized if something went wrong prior to the dependency
      // initialization.
      di.getOrNull<CrashlyticsService>()?.recordError(
        error,
        stackTrace,
        fatal: true,
      );
    },
  );
}
