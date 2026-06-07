// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:alerter/alerter.dart' as _i103;
import 'package:analytics/analytics.dart' as _i548;
import 'package:app_logger/app_logger.dart' as _i519;
import 'package:app_template/di/modules/app_module.dart' as _i384;
import 'package:app_template/di/modules/auth_module.dart' as _i228;
import 'package:app_template/di/modules/settings_module.dart' as _i150;
import 'package:app_template/di/modules/user_data_module.dart' as _i201;
import 'package:app_template/features/app/application/services/app_initializer_service.dart'
    as _i707;
import 'package:app_template/features/app/application/services/session_initializer_service.dart'
    as _i741;
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
import 'package:app_template/features/app/presentation/widgets/app_root/app_root_bloc.dart'
    as _i625;
import 'package:app_template/features/auth/data/clients/app_server_token_refresh_api_client.dart'
    as _i524;
import 'package:app_template/features/auth/data/repositories/auth_data_mapper.dart'
    as _i704;
import 'package:app_template/features/auth/data/repositories/auth_refresh_error_mapper.dart'
    as _i82;
import 'package:app_template/features/auth/data/sources/local_auth_data_source.dart'
    as _i30;
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart'
    as _i156;
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart'
    as _i731;
import 'package:app_template/features/auth/domain/services/auth_data_service.dart'
    as _i374;
import 'package:app_template/features/settings/application/services/app_locale_resolver.dart'
    as _i972;
import 'package:app_template/features/settings/application/services/platform_settings_provider.dart'
    as _i322;
import 'package:app_template/features/settings/application/services/settings_service.dart'
    as _i658;
import 'package:app_template/features/settings/data/models/settings_dto.dart'
    as _i801;
import 'package:app_template/features/settings/data/sources/settings_data_source.dart'
    as _i850;
import 'package:app_template/features/settings/domain/models/app_settings.dart'
    as _i78;
import 'package:app_template/features/settings/domain/repositories/settings_repository.dart'
    as _i612;
import 'package:app_template/features/user_data/data/models/user_data_dto.dart'
    as _i1018;
import 'package:app_template/features/user_data/data/sources/user_data_data_source.dart'
    as _i257;
import 'package:app_template/features/user_data/domain/models/user_data.dart'
    as _i436;
import 'package:app_template/features/user_data/domain/repositories/user_data_repository.dart'
    as _i728;
import 'package:app_template/features/user_data/domain/services/user_data_service.dart'
    as _i84;
import 'package:app_template/router/app_router.dart' as _i204;
import 'package:crashlytics/crashlytics.dart' as _i35;
import 'package:data_domain_converters/data_domain_converters.dart' as _i1003;
import 'package:dlogger/dlogger.dart' as _i975;
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:net_kit/net_kit.dart' as _i535;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:preference_store/preference_store.dart' as _i300;
import 'package:snacker/snacker.dart' as _i1020;
import 'package:sqlite_db/sqlite_db.dart' as _i860;

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
    final authModule = _$AuthModule();
    final settingsModule = _$SettingsModule();
    final userDataModule = _$UserDataModule();
    final appModule = _$AppModule();
    gh.factory<_i704.AuthDataMapper>(() => authModule.getAuthDataMapper());
    gh.factory<_i82.AuthRefreshErrorMapper>(
      () => authModule.getAuthRefreshErrorMapper(),
    );
    gh.factory<_i1003.DataDomainConverter<_i801.SettingsDTO, _i78.AppSettings>>(
      () => settingsModule.getSettingsMapper(),
    );
    gh.factory<_i1003.DataDomainConverter<_i1018.UserDataDTO, _i436.UserData>>(
      () => userDataModule.getUserDataMapper(),
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
    gh.singleton<_i975.LogPolicyController>(
      () => appModule.getLogPolicyController(),
    );
    gh.singleton<_i300.PreferenceStore>(
      () => appModule.getSharedPreferenceStore(),
    );
    gh.singleton<_i548.AnalyticsService>(() => appModule.getAnalyticsService());
    gh.singleton<_i35.CrashlyticsService>(
      () => appModule.getCrashlyticsService(),
    );
    gh.singleton<_i291.FallbackLocaleSelector>(
      () => appModule.getFallbackLocaleSelector(),
    );
    gh.singleton<_i322.PlatformSettingsProvider>(
      () => settingsModule.getPlatformSettingsProvider(),
    );
    gh.singleton<_i972.AppLocaleResolver>(
      () => settingsModule.getAppLocaleResolver(),
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getStageFlavorConfig(),
      registerFor: {_stage},
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getDevFlavorConfig(),
      registerFor: {_dev},
    );
    gh.singleton<_i519.AppLogger>(
      () => appModule.getLogger(
        gh<_i527.AppDirectories>(),
        gh<_i975.LogPolicyController>(),
      ),
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getExpFlavorConfig(),
      registerFor: {_exp},
    );
    gh.singleton<_i803.AppConfigFactory>(
      () => appModule.getAppConfigFactory(
        gh<_i655.PackageInfo>(),
        gh<_i291.FallbackLocaleSelector>(),
      ),
    );
    gh.singleton<_i103.Alerter>(
      () => appModule.getAlerter(gh<_i409.GlobalKey<_i409.NavigatorState>>()),
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getProdFlavorConfig(),
      registerFor: {_prod},
    );
    gh.singleton<_i30.LocalAuthDataSource>(
      () => authModule.getLocalAuthDataSource(gh<_i300.PreferenceStore>()),
    );
    gh.singleton<_i850.SettingsDataSource>(
      () => settingsModule.getSettingsDataSource(gh<_i300.PreferenceStore>()),
    );
    gh.singleton<_i860.SQLiteDb>(
      () => appModule.getAppDatabase(gh<_i527.AppDirectories>()),
    );
    gh.singleton<_i1020.Snacker>(
      () => appModule.getSnacker(
        gh<_i409.GlobalKey<_i409.ScaffoldMessengerState>>(),
      ),
    );
    gh.singleton<_i707.AppInitializerService>(
      () => appModule.getAppInitializerService(
        gh<_i548.AnalyticsService>(),
        gh<_i35.CrashlyticsService>(),
        gh<_i860.SQLiteDb>(),
      ),
    );
    gh.singleton<_i143.BuildMetadata>(
      () => appModule.getBuildMetadata(
        gh<_i821.FlavorConfig>(),
        gh<_i655.PackageInfo>(),
      ),
    );
    gh.singleton<_i257.UserDataDataSource>(
      () => userDataModule.getUserDataDataSource(gh<_i860.SQLiteDb>()),
    );
    gh.singleton<_i612.SettingsRepository>(
      () => settingsModule.getSettingsRepository(
        gh<_i1003.DataDomainConverter<_i801.SettingsDTO, _i78.AppSettings>>(),
        gh<_i850.SettingsDataSource>(),
      ),
    );
    gh.singleton<_i728.UserDataRepository>(
      () => userDataModule.getUserDataRepository(
        gh<_i1003.DataDomainConverter<_i1018.UserDataDTO, _i436.UserData>>(),
        gh<_i257.UserDataDataSource>(),
      ),
    );
    gh.singleton<_i658.SettingsService>(
      () => settingsModule.getSettingsService(
        gh<_i972.AppLocaleResolver>(),
        gh<_i322.PlatformSettingsProvider>(),
        gh<_i612.SettingsRepository>(),
      ),
    );
    gh.singleton<_i84.UserDataService>(
      () => userDataModule.getUserDataService(gh<_i728.UserDataRepository>()),
    );
    gh.singleton<_i535.NetClient>(
      () => appModule.getAppServerPublicApiClient(
        gh<_i821.FlavorConfig>(),
        gh<_i143.BuildMetadata>(),
        gh<_i658.SettingsService>(),
        gh<_i519.AppLogger>(),
      ),
      instanceName: 'APP_SERVER_PUBLIC_API_CLIENT',
    );
    gh.factory<_i524.AppServerTokenRefreshApiClient>(
      () => appModule.getAppServerTokenRefresherApiClient(
        gh<_i821.FlavorConfig>(),
        gh<_i143.BuildMetadata>(),
        gh<_i519.AppLogger>(),
        gh<_i658.SettingsService>(),
      ),
    );
    gh.singleton<_i156.RemoteAuthDataSource>(
      () => authModule.getRemoteAuthDataSource(
        gh<_i524.AppServerTokenRefreshApiClient>(),
      ),
    );
    gh.singleton<_i731.AuthDataRepository>(
      () => authModule.getAuthDataRepository(
        gh<_i704.AuthDataMapper>(),
        gh<_i82.AuthRefreshErrorMapper>(),
        gh<_i30.LocalAuthDataSource>(),
        gh<_i156.RemoteAuthDataSource>(),
      ),
    );
    gh.singleton<_i374.AuthDataService>(
      () => authModule.getAuthDataService(gh<_i731.AuthDataRepository>()),
    );
    gh.singleton<_i741.SessionInitializerService>(
      () => appModule.getSessionInitializerService(
        gh<_i374.AuthDataService>(),
        gh<_i548.AnalyticsService>(),
        gh<_i35.CrashlyticsService>(),
      ),
    );
    gh.singleton<_i625.AppRootBloc>(
      () => appModule.getAppRootBloc(
        gh<_i519.AppLogger>(),
        gh<_i374.AuthDataService>(),
        gh<_i658.SettingsService>(),
        gh<_i707.AppInitializerService>(),
        gh<_i741.SessionInitializerService>(),
      ),
    );
    gh.singleton<_i535.NetClient>(
      () => appModule.getAppServerPrivateApiClient(
        gh<_i821.FlavorConfig>(),
        gh<_i143.BuildMetadata>(),
        gh<_i519.AppLogger>(),
        gh<_i374.AuthDataService>(),
        gh<_i658.SettingsService>(),
        gh<_i524.AppServerTokenRefreshApiClient>(),
      ),
      instanceName: 'APP_SERVER_PRIVATE_API_CLIENT',
    );
    gh.singleton<_i204.AppRouter>(
      () => appModule.getAppRouter(
        gh<_i409.GlobalKey<_i409.NavigatorState>>(),
        gh<_i519.AppLogger>(),
        gh<_i374.AuthDataService>(),
      ),
    );
    return this;
  }
}

class _$AuthModule extends _i228.AuthModule {}

class _$SettingsModule extends _i150.SettingsModule {}

class _$UserDataModule extends _i201.UserDataModule {}

class _$AppModule extends _i384.AppModule {}
