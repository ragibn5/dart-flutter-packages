// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_template/core/converters/data_domain_converter.dart'
    as _i875;
import 'package:app_template/core/infrastructure/storage/database/sqlite_db.dart'
    as _i998;
import 'package:app_template/core/infrastructure/storage/preference/preference_store.dart'
    as _i266;
import 'package:app_template/features/app/application/services/app_initializer_service.dart'
    as _i707;
import 'package:app_template/features/app/application/services/session_initializer_service.dart'
    as _i741;
import 'package:app_template/features/app/di/modules/app_module.dart' as _i393;
import 'package:app_template/features/app/infrastructure/models/app_directories.dart'
    as _i527;
import 'package:app_template/features/app/infrastructure/models/build_metadata.dart'
    as _i143;
import 'package:app_template/features/app/infrastructure/models/flavor_config.dart'
    as _i821;
import 'package:app_template/features/app/infrastructure/services/app_config_factory.dart'
    as _i803;
import 'package:app_template/features/app/infrastructure/services/fallback_locale_selector.dart'
    as _i291;
import 'package:app_template/features/app/presentation/bloc/app_bloc.dart'
    as _i511;
import 'package:app_template/features/auth/data/mappers/auth_data_mapper.dart'
    as _i907;
import 'package:app_template/features/auth/data/mappers/auth_refresh_error_mapper.dart'
    as _i315;
import 'package:app_template/features/auth/data/repositories/auth_data_repository_impl.dart'
    as _i16;
import 'package:app_template/features/auth/data/sources/local_auth_data_source.dart'
    as _i30;
import 'package:app_template/features/auth/data/sources/local_auth_data_source_impl.dart'
    as _i451;
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart'
    as _i156;
import 'package:app_template/features/auth/data/sources/remote_auth_data_source_impl.dart'
    as _i752;
import 'package:app_template/features/auth/di/modules/auth_module.dart'
    as _i1052;
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart'
    as _i731;
import 'package:app_template/features/auth/domain/services/auth_data_service.dart'
    as _i374;
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client.dart'
    as _i120;
import 'package:app_template/features/settings/application/services/app_locale_resolver.dart'
    as _i178;
import 'package:app_template/features/settings/application/services/platform_settings_provider.dart'
    as _i898;
import 'package:app_template/features/settings/application/services/settings_service.dart'
    as _i178;
import 'package:app_template/features/settings/data/mappers/settings_mapper.dart'
    as _i677;
import 'package:app_template/features/settings/data/models/settings_dto.dart'
    as _i801;
import 'package:app_template/features/settings/data/repositories/settings_repository_impl.dart'
    as _i584;
import 'package:app_template/features/settings/data/sources/settings_data_source.dart'
    as _i850;
import 'package:app_template/features/settings/data/sources/settings_data_source_impl.dart'
    as _i886;
import 'package:app_template/features/settings/di/modules/settings_module.dart'
    as _i885;
import 'package:app_template/features/settings/domain/models/app_settings.dart'
    as _i78;
import 'package:app_template/features/settings/domain/repositories/settings_repository.dart'
    as _i612;
import 'package:app_template/features/settings/infrastructures/services/platform_settings_provider_impl.dart'
    as _i423;
import 'package:app_template/features/user_data/data/mappers/user_data_mapper.dart'
    as _i343;
import 'package:app_template/features/user_data/data/models/user_data_dto.dart'
    as _i1018;
import 'package:app_template/features/user_data/data/repositories/user_data_repository_impl.dart'
    as _i393;
import 'package:app_template/features/user_data/data/sources/user_data_data_source.dart'
    as _i257;
import 'package:app_template/features/user_data/data/sources/user_data_data_source_impl.dart'
    as _i785;
import 'package:app_template/features/user_data/di/modules/user_data_module.dart'
    as _i151;
import 'package:app_template/features/user_data/domain/models/user_data.dart'
    as _i436;
import 'package:app_template/features/user_data/domain/repositories/user_data_repository.dart'
    as _i728;
import 'package:app_template/features/user_data/domain/services/user_data_service.dart'
    as _i84;
import 'package:app_template/router/app_router.dart' as _i204;
import 'package:app_template/shared/alerter/alerter.dart' as _i518;
import 'package:app_template/shared/alerter/router_navigator_based_alerter.dart'
    as _i751;
import 'package:app_template/shared/analytics/analytics_service.dart' as _i814;
import 'package:app_template/shared/analytics/firebase_analytics_service.dart'
    as _i1009;
import 'package:app_template/shared/crashlytics/crashlytics_service.dart'
    as _i125;
import 'package:app_template/shared/crashlytics/firebase_crashlytics_service.dart'
    as _i333;
import 'package:app_template/shared/di/modules/shared_module.dart' as _i885;
import 'package:app_template/shared/logger/app_log_policy_controller.dart'
    as _i644;
import 'package:app_template/shared/logger/app_log_policy_controller_impl.dart'
    as _i948;
import 'package:app_template/shared/logger/app_logger.dart' as _i1054;
import 'package:app_template/shared/snacker/scaffold_messenger_based_snacker.dart'
    as _i916;
import 'package:app_template/shared/snacker/snacker.dart' as _i638;
import 'package:dlogger/dlogger.dart' as _i975;
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:net_kit/net_kit.dart' as _i535;
import 'package:package_info_plus/package_info_plus.dart' as _i655;

const String _stage = 'stage';
const String _dev = 'dev';
const String _exp = 'exp';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    final settingsModule = _$SettingsModule();
    final sharedModule = _$SharedModule();
    final authModule = _$AuthModule();
    final userDataModule = _$UserDataModule();
    gh.factory<_i907.AuthDataMapper>(() => _i907.AuthDataMapper());
    gh.factory<_i315.AuthRefreshErrorMapper>(
      () => _i315.AuthRefreshErrorMapper(),
    );
    await gh.singletonAsync<_i655.PackageInfo>(
      () => appModule.getPackageInfo(),
      preResolve: true,
    );
    await gh.singletonAsync<_i527.AppDirectories>(
      () => appModule.getAppDirectories(),
      preResolve: true,
    );
    gh.singleton<_i409.GlobalKey<_i409.NavigatorState>>(
      () => appModule.getGlobalNavigatorState(),
    );
    gh.singleton<_i409.GlobalKey<_i409.ScaffoldMessengerState>>(
      () => appModule.getGlobalScaffoldMessengerState(),
    );
    gh.singleton<_i291.FallbackLocaleSelector>(
      () => const _i291.FallbackLocaleSelector(),
    );
    gh.singleton<_i178.AppLocaleResolver>(
      () => settingsModule.getAppLocaleResolver(),
    );
    gh.singleton<_i975.LogPolicyController>(
      () => sharedModule.getLogPolicyController(),
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getStageFlavorConfig(),
      registerFor: {_stage},
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getDevFlavorConfig(),
      registerFor: {_dev},
    );
    gh.singleton<_i814.AnalyticsService>(
      () => _i1009.FirebaseAnalyticsService(),
    );
    gh.singleton<_i1054.AppLogger>(
      () => sharedModule.getLogger(
        gh<_i527.AppDirectories>(),
        gh<_i975.LogPolicyController>(),
      ),
    );
    gh.singleton<_i898.PlatformSettingsProvider>(
      () => _i423.PlatformSettingsProviderImpl(),
    );
    gh.singleton<
      _i875.DataDomainConverter<_i801.SettingsDTO, _i78.AppSettings>
    >(() => _i677.SettingsMapper());
    gh.singleton<_i803.AppConfigFactory>(
      () => _i803.AppConfigFactory(
        gh<_i655.PackageInfo>(),
        gh<_i291.FallbackLocaleSelector>(),
      ),
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getExpFlavorConfig(),
      registerFor: {_exp},
    );
    gh.singleton<_i125.CrashlyticsService>(
      () => _i333.FirebaseCrashlyticsService(),
    );
    gh.singleton<_i875.DataDomainConverter<_i1018.UserDataDTO, _i436.UserData>>(
      () => _i343.UserDataMapper(),
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getProdFlavorConfig(),
      registerFor: {_prod},
    );
    gh.singleton<_i638.Snacker>(
      () => _i916.ScaffoldMessengerBasedSnacker(
        gh<_i409.GlobalKey<_i409.ScaffoldMessengerState>>(),
      ),
    );
    gh.singleton<_i518.Alerter>(
      () => _i751.RouterNavigatorBasedAlerter(
        gh<_i409.GlobalKey<_i409.NavigatorState>>(),
      ),
    );
    gh.singleton<_i644.AppLogPolicyController>(
      () => _i948.AppLogPolicyControllerImpl(gh<_i975.LogPolicyController>()),
    );
    gh.factory<_i998.SQLiteDb>(
      () => sharedModule.getAppDatabase(gh<_i527.AppDirectories>()),
    );
    gh.singleton<_i266.PreferenceStore>(
      () => sharedModule.getSharedPreferenceStore(gh<_i821.FlavorConfig>()),
    );
    gh.factory<_i850.SettingsDataSource>(
      () => _i886.SettingsDataSourceImpl(gh<_i266.PreferenceStore>()),
    );
    gh.singleton<_i143.BuildMetadata>(
      () => appModule.getBuildMetadata(
        gh<_i821.FlavorConfig>(),
        gh<_i655.PackageInfo>(),
      ),
    );
    gh.factory<_i612.SettingsRepository>(
      () => _i584.SettingsRepositoryImpl(
        gh<_i875.DataDomainConverter<_i801.SettingsDTO, _i78.AppSettings>>(),
        gh<_i850.SettingsDataSource>(),
      ),
    );
    gh.singleton<_i707.AppInitializerService>(
      () => appModule.getAppInitializerService(
        gh<_i814.AnalyticsService>(),
        gh<_i125.CrashlyticsService>(),
        gh<_i998.SQLiteDb>(),
      ),
    );
    gh.singleton<_i178.SettingsService>(
      () => settingsModule.getSettingsService(
        gh<_i178.AppLocaleResolver>(),
        gh<_i898.PlatformSettingsProvider>(),
        gh<_i612.SettingsRepository>(),
      ),
    );
    gh.singleton<_i30.LocalAuthDataSource>(
      () => _i451.LocalAuthDataSourceImpl(gh<_i266.PreferenceStore>()),
    );
    gh.factory<_i120.AppServerTokenRefreshApiClient>(
      () => sharedModule.getAppServerTokenRefresherApiClient(
        gh<_i821.FlavorConfig>(),
        gh<_i143.BuildMetadata>(),
        gh<_i1054.AppLogger>(),
        gh<_i178.SettingsService>(),
      ),
    );
    gh.singleton<_i257.UserDataDataSource>(
      () => _i785.UserDataDataSourceImpl(gh<_i998.SQLiteDb>()),
    );
    gh.singleton<_i535.NetClient>(
      () => sharedModule.getAppServerPublicApiClient(
        gh<_i821.FlavorConfig>(),
        gh<_i143.BuildMetadata>(),
        gh<_i178.SettingsService>(),
        gh<_i1054.AppLogger>(),
      ),
      instanceName: 'APP_SERVER_PUBLIC_API_CLIENT',
    );
    gh.singleton<_i156.RemoteAuthDataSource>(
      () => _i752.RemoteAuthDataSourceImpl(
        gh<_i120.AppServerTokenRefreshApiClient>(),
      ),
    );
    gh.singleton<_i731.AuthDataRepository>(
      () => _i16.AuthDataRepositoryImpl(
        gh<_i907.AuthDataMapper>(),
        gh<_i315.AuthRefreshErrorMapper>(),
        gh<_i30.LocalAuthDataSource>(),
        gh<_i156.RemoteAuthDataSource>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i374.AuthDataService>(
      () => authModule.getAuthDataService(gh<_i731.AuthDataRepository>()),
    );
    gh.singleton<_i728.UserDataRepository>(
      () => _i393.UserDataRepositoryImpl(
        gh<_i875.DataDomainConverter<_i1018.UserDataDTO, _i436.UserData>>(),
        gh<_i257.UserDataDataSource>(),
      ),
    );
    gh.singleton<_i741.SessionInitializerService>(
      () => appModule.getSessionInitializerService(
        gh<_i374.AuthDataService>(),
        gh<_i814.AnalyticsService>(),
        gh<_i125.CrashlyticsService>(),
      ),
    );
    gh.singleton<_i535.NetClient>(
      () => sharedModule.getAppServerPrivateApiClient(
        gh<_i821.FlavorConfig>(),
        gh<_i143.BuildMetadata>(),
        gh<_i1054.AppLogger>(),
        gh<_i374.AuthDataService>(),
        gh<_i178.SettingsService>(),
        gh<_i120.AppServerTokenRefreshApiClient>(),
      ),
      instanceName: 'APP_SERVER_PRIVATE_API_CLIENT',
    );
    gh.singleton<_i84.UserDataService>(
      () => userDataModule.getUserDataService(gh<_i728.UserDataRepository>()),
    );
    gh.singleton<_i204.AppRouter>(
      () => _i204.AppRouter(
        gh<_i409.GlobalKey<_i409.NavigatorState>>(),
        gh<_i1054.AppLogger>(),
        gh<_i374.AuthDataService>(),
      ),
    );
    gh.singleton<_i511.AppBloc>(
      () => _i511.AppBloc(
        gh<_i1054.AppLogger>(),
        gh<_i374.AuthDataService>(),
        gh<_i178.SettingsService>(),
        gh<_i707.AppInitializerService>(),
        gh<_i741.SessionInitializerService>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i393.AppModule {}

class _$SettingsModule extends _i885.SettingsModule {}

class _$SharedModule extends _i885.SharedModule {}

class _$AuthModule extends _i1052.AuthModule {}

class _$UserDataModule extends _i151.UserDataModule {}
