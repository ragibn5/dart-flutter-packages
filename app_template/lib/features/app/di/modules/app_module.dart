import 'dart:io';

import 'package:alerter/alerter.dart';
import 'package:analytics/analytics.dart';
import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/app/application/services/app_initializer_service.dart';
import 'package:app_template/features/app/application/services/session_initializer_service.dart';
import 'package:app_template/features/app/infrastructure/models/app_directories.dart';
import 'package:app_template/features/app/infrastructure/models/app_flavor.dart';
import 'package:app_template/features/app/infrastructure/models/build_metadata.dart';
import 'package:app_template/features/app/infrastructure/models/flavor_config.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/auth_interceptor.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/logger_interceptor.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/metadata_adder_interceptor.dart';
import 'package:app_template/features/auth/data/clients/app_server_token_refresh_api_client.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client_impl.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/user_data/infrastructure/database/user_data_table_constants.dart';
import 'package:crashlytics/crashlytics.dart';
import 'package:dlogger/dlogger.dart' hide Logger;
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:net_kit/net_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:preference_store/preference_store.dart';
import 'package:snacker/snacker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_db/sqlite_db.dart';

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
  LogPolicyController getLogPolicyController() {
    return DefaultLogPolicyController();
  }

  @singleton
  AppLogger getLogger(
    AppDirectories appDirectories,
    LogPolicyController logPolicyController,
  ) {
    return const AppLoggerFactory().create(
      filters: [PolicyBasedLogFilter(logPolicyController)],
      loggers: {
        'console': ConsoleLogger(),
        'file': FileLogger(
          logDirectory: appDirectories.logDirectory,
          fileNameBuilder: (data) =>
              'LOG-${DateFormat('dd-MM-yyyy').format(data.stamp)}.log',
        ),
      },
    );
  }

  @singleton
  PreferenceStore getSharedPreferenceStore() {
    return const PreferenceStoreFactory().create();
  }

  @singleton
  SQLiteDb getAppDatabase(AppDirectories appDirectories) {
    const appDbVersion = 1;
    const appDbName = 'APP_DB';

    String escape(String identifier) {
      return '"${identifier.replaceAll('"', '""')}"';
    }

    return const SQLiteDbFactory().create(
      DbConnectionData(
        hostDirectoryPath: path.join(
          appDirectories.databaseDirectory.path,
          appDbName,
        ),
        name: appDbName,
        version: appDbVersion,
      ),
      DbInitializerScripts(
        creationScripts: [
          SingleVersionedDbScript(
            targetVersion: appDbVersion,
            scriptText:
                '''
                CREATE TABLE ${escape(UserDataTableConstants.NAME)} (
                  ${escape(UserDataTableConstants.COLUMN_ID)} TEXT NOT NULL UNIQUE,
                  ${escape(UserDataTableConstants.COLUMN_NAME)} TEXT NOT NULL,
                  PRIMARY KEY(${escape(UserDataTableConstants.COLUMN_ID)})
                );
                ''',
          ),
        ],
      ),
    );
  }

  @singleton
  @Named(APP_SERVER_PUBLIC_API_CLIENT)
  NetClient getAppServerPublicApiClient(
    FlavorConfig flavorConfig,
    BuildMetadata buildMetadata,
    SettingsService settingsService,
    AppLogger logger,
  ) {
    final client = NetClientFactory().create(
      ClientConfig(
        baseUrl: flavorConfig.baseUrl,
        connectionTimeout: const Duration(seconds: 10),
      ),
    );

    client.interceptors.addAll([
      MetadataAdderInterceptor(buildMetadata, settingsService),
      LoggerInterceptor(logger),
    ]);

    return client;
  }

  @singleton
  @Named(APP_SERVER_PRIVATE_API_CLIENT)
  NetClient getAppServerPrivateApiClient(
    FlavorConfig flavorConfig,
    BuildMetadata buildMetadata,
    AppLogger logger,
    AuthDataService authDataService,
    SettingsService settingsService,
    AppServerTokenRefreshApiClient tokenRefreshApiClient,
  ) {
    final client = NetClientFactory().create(
      ClientConfig(
        baseUrl: flavorConfig.baseUrl,
        connectionTimeout: const Duration(seconds: 10),
      ),
    );

    client.interceptors.addAll([
      MetadataAdderInterceptor(buildMetadata, settingsService),
      AuthInterceptor(client, authDataService),
      LoggerInterceptor(logger),
    ]);

    return client;
  }

  AppServerTokenRefreshApiClient getAppServerTokenRefresherApiClient(
    FlavorConfig flavorConfig,
    BuildMetadata buildMetadata,
    AppLogger logger,
    SettingsService settingsService,
  ) {
    final client = NetClientFactory().create(
      ClientConfig(
        baseUrl: flavorConfig.baseUrl,
        connectionTimeout: const Duration(seconds: 10),
      ),
    );

    client.interceptors.addAll([
      MetadataAdderInterceptor(buildMetadata, settingsService),
      LoggerInterceptor(logger),
    ]);

    return AppServerTokenRefreshApiClientImpl(client);
  }

  @singleton
  Alerter getAlerter(GlobalKey<NavigatorState> navigatorKey) {
    return RouterNavigatorAlerter(navigatorKey);
  }

  @singleton
  AnalyticsService getAnalyticsService() {
    return const AnalyticsServiceFactory().create();
  }

  @singleton
  CrashlyticsService getCrashlyticsService() {
    return const CrashlyticsServiceFactory().create();
  }

  @singleton
  Snacker getSnacker(GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {
    return ScaffoldMessengerSnacker(scaffoldMessengerKey);
  }

  @singleton
  AppInitializerService getAppInitializerService(
    AnalyticsService analyticsService,
    CrashlyticsService crashlyticsService,
    SQLiteDb appDatabase,
  ) {
    return AppInitializerService(
      crashlyticsService,
      analyticsService,
      appDatabase,
    );
  }

  @singleton
  SessionInitializerService getSessionInitializerService(
    AuthDataService authDataService,
    AnalyticsService analyticsService,
    CrashlyticsService crashlyticsService,
  ) {
    return SessionInitializerService(
      authDataService,
      analyticsService,
      crashlyticsService,
    );
  }
}
