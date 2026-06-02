import 'package:app_template/core/infrastructure/storage/database/sqlite_db.dart';
import 'package:app_template/core/infrastructure/storage/preference/preference_store.dart';
import 'package:app_template/features/app/infrastructure/models/app_directories.dart';
import 'package:app_template/features/app/infrastructure/models/build_metadata.dart';
import 'package:app_template/features/app/infrastructure/models/flavor_config.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client_impl.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/user_data/infrastructure/database/user_data_table_constants.dart';
import 'package:app_template/shared/logger/app_logger.dart';
import 'package:app_template/shared/logger/app_logger_id.dart';
import 'package:app_template/shared/logger/app_logger_impl.dart';
import 'package:app_template/shared/network/interceptors/auth_interceptor.dart';
import 'package:app_template/shared/network/interceptors/logger_interceptor.dart';
import 'package:app_template/shared/network/interceptors/metadata_adder_interceptor.dart';
import 'package:app_template/shared/storage/database/app_database.dart';
import 'package:app_template/shared/storage/database/models/db_connection_data.dart';
import 'package:app_template/shared/storage/database/models/db_initialization_scripts.dart';
import 'package:app_template/shared/storage/database/models/db_script.dart';
import 'package:app_template/shared/storage/preference/shared_preferences_store.dart';
import 'package:dlogger/dlogger.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:net_kit/net_kit.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

const String APP_SERVER_PUBLIC_API_CLIENT = 'APP_SERVER_PUBLIC_API_CLIENT';
const String APP_SERVER_PRIVATE_API_CLIENT = 'APP_SERVER_PRIVATE_API_CLIENT';

@module
abstract class SharedModule {
  @singleton
  LogPolicyController getLogPolicyController() {
    return DefaultLogPolicyController();
  }

  @singleton
  AppLogger getLogger(
    AppDirectories appDirectories,
    LogPolicyController logPolicyController,
  ) {
    return AppLoggerImpl(
      [PolicyBasedLogFilter(logPolicyController)],
      {
        AppLoggerId.CONSOLE: ConsoleLogger(),
        AppLoggerId.FILE: FileLogger(
          logDirectory: appDirectories.logDirectory,
          fileNameBuilder: (data) =>
              'LOG-${DateFormat('dd-MM-yyyy').format(data.stamp)}.log',
        ),
      },
    );
  }

  @singleton
  PreferenceStore getSharedPreferenceStore(FlavorConfig flavorConfig) {
    return SharedPreferencesStore(SharedPreferencesAsync());
  }

  @singleton
  SQLiteDb getAppDatabase(AppDirectories appDirectories) {
    const appDbVersion = 1;
    const appDbName = 'APP_DB';

    String escape(String identifier) {
      return '"${identifier.replaceAll('"', '""')}"';
    }

    return AppDatabase(
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
}
