import 'dart:async';
import 'dart:ui';

import 'package:app_template/di/provider/dependency_provider.dart';
import 'package:app_template/features/app/infrastructure/models/app_config.dart';
import 'package:app_template/features/app/infrastructure/models/startup_config.dart';
import 'package:app_template/features/app/presentation/bloc/app_bloc.dart';
import 'package:app_template/features/app/presentation/widgets/app_root.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/generated/l10n.dart';
import 'package:app_template/router/app_router.dart';
import 'package:app_template/shared/crashlytics/crashlytics_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> runFlavoredApp({required StartupConfig startupConfig}) async {
  await runZonedGuarded(
    () async {
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      final platformDispatcher = widgetsBinding.platformDispatcher;

      // Present the splash screen while we do app initialization.
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      // Set up core services
      await Firebase.initializeApp(options: startupConfig.firebaseOptions);
      await di.initialize(startupConfig.flavor);

      // Run the app
      runApp(
        BlocProvider(
          create: (context) =>
              di.get<AppBloc>()..add(AppInitializationRequested()),
          child: AppRoot(
            router: di.get<AppRouter>(),
            authDataService: di.get<AuthDataService>(),
            scaffoldMessengerKey: di.get<GlobalKey<ScaffoldMessengerState>>(),
            platformConfig: AppConfig(
              restorationScopeId: di.get<PackageInfo>().packageName,
              designSize: const Size(360, 640),
              lightThemeData: ThemeData.light(),
              darkThemeData: ThemeData.dark(),
              supportedLocales: S.delegate.supportedLocales,
              defaultThemeMode: ThemeMode.system,
              defaultLocale: _determineDefaultLocale(
                S.delegate.supportedLocales.first,
                S.delegate.supportedLocales,
                platformDispatcher,
              ),
              localizationDelegates: [
                S.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          ),
        ),
      );

      // Remove the splash screen.
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

Locale _determineDefaultLocale(
  Locale defaultLocale,
  List<Locale> supportedLocales,
  PlatformDispatcher platformDispatcher,
) {
  final platformLocale = platformDispatcher.locale;
  final matchFromPlatform = supportedLocales
      .where((l) => l.languageCode == platformLocale.languageCode)
      .firstOrNull;

  return matchFromPlatform ?? defaultLocale;
}
