import 'dart:io';

import 'package:app_template/core/infrastructure/storage/database/sqlite_db.dart';
import 'package:app_template/features/app/application/services/app_initializer_service.dart';
import 'package:app_template/features/app/application/services/app_initializer_service_impl.dart';
import 'package:app_template/features/app/application/services/session_initializer_service.dart';
import 'package:app_template/features/app/application/services/session_initializer_service_impl.dart';
import 'package:app_template/features/app/infrastructure/models/app_directories.dart';
import 'package:app_template/features/app/infrastructure/models/app_flavor.dart';
import 'package:app_template/features/app/infrastructure/models/build_metadata.dart';
import 'package:app_template/features/app/infrastructure/models/flavor_config.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/shared/analytics/analytics_service.dart';
import 'package:app_template/shared/crashlytics/crashlytics_service.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const String APP_SERVER_PUBLIC_API_CLIENT = 'APP_SERVER_PUBLIC_API_CLIENT';
const String APP_SERVER_PRIVATE_API_CLIENT = 'APP_SERVER_PRIVATE_API_CLIENT';

@module
abstract class AppModule {
  @Singleton(env: [AppFlavor.FLAVOR_NAME_DEV])
  FlavorConfig getDevFlavorConfig() {
    // TODO: CHANGE THE URLS
    return FlavorConfig(
      flavor: AppFlavor.DEV.name,
      baseUrl: 'https://dev.yourserver.com',
      storageBucketUrl: 'https://dev.yourbucket.com',
    );
  }

  @Singleton(env: [AppFlavor.FLAVOR_NAME_EXP])
  FlavorConfig getExpFlavorConfig() {
    // TODO: CHANGE THE URLS
    return FlavorConfig(
      flavor: AppFlavor.EXP.name,
      baseUrl: 'https://exp.yourserver.com',
      storageBucketUrl: 'https://exp.yourbucket.com',
    );
  }

  @Singleton(env: [AppFlavor.FLAVOR_NAME_STAGE])
  FlavorConfig getStageFlavorConfig() {
    // TODO: CHANGE THE URLS
    return FlavorConfig(
      flavor: AppFlavor.STAGE.name,
      baseUrl: 'https://stage.yourserver.com',
      storageBucketUrl: 'https://stage.yourbucket.com',
    );
  }

  @Singleton(env: [AppFlavor.FLAVOR_NAME_PROD])
  FlavorConfig getProdFlavorConfig() {
    // TODO: CHANGE THE URLS
    return FlavorConfig(
      flavor: AppFlavor.PROD.name,
      baseUrl: 'https://yourserver.com',
      storageBucketUrl: 'https://yourbucket.com',
    );
  }

  @singleton
  @preResolve
  Future<PackageInfo> getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @singleton
  @preResolve
  Future<AppDirectories> getAppDirectories() async {
    return AppDirectories(
      logDirectory: Directory(
        path.join((await getApplicationCacheDirectory()).path, 'logs'),
      ),
      databaseDirectory: Directory(await getDatabasesPath()),
    );
  }

  @singleton
  BuildMetadata getBuildMetadata(
    FlavorConfig flavorConfig,
    PackageInfo packageInfo,
  ) {
    return BuildMetadata(
      scope: 'flutter',
      platform: Platform.operatingSystem,
      platformVersion: Platform.operatingSystemVersion,
      runtime: 'dart',
      runtimeVersion: Platform.version,
      packageName: packageInfo.packageName,
      flavor: flavorConfig.flavor,
      versionName: packageInfo.version,
      versionCode: packageInfo.buildNumber,
    );
  }

  @singleton
  GlobalKey<NavigatorState> getGlobalNavigatorState() {
    return GlobalKey<NavigatorState>();
  }

  @singleton
  GlobalKey<ScaffoldMessengerState> getGlobalScaffoldMessengerState() {
    return GlobalKey<ScaffoldMessengerState>();
  }

  @singleton
  AppInitializerService getAppInitializerService(
    AnalyticsService analyticsService,
    CrashlyticsService crashlyticsService,
    SQLiteDb appDatabase,
  ) {
    return AppInitializerServiceImpl([
      crashlyticsService,
      analyticsService,
      appDatabase,
    ]);
  }

  @singleton
  SessionInitializerService getSessionInitializerService(
    AuthDataService authDataService,
    AnalyticsService analyticsService,
    CrashlyticsService crashlyticsService,
  ) {
    return SessionInitializerServiceImpl(
      authDataService,
      analyticsService,
      crashlyticsService,
    );
  }
}
