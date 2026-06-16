import 'package:app_template/features/settings/application/services/app_locale_resolver.dart';
import 'package:app_template/features/settings/application/services/platform_settings_provider.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/settings/application/services/settings_service_impl.dart';
import 'package:app_template/features/settings/data/mappers/settings_mapper.dart';
import 'package:app_template/features/settings/data/models/settings_dto.dart';
import 'package:app_template/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:app_template/features/settings/data/sources/settings_data_source.dart';
import 'package:app_template/features/settings/data/sources/settings_data_source_impl.dart';
import 'package:app_template/features/settings/domain/models/app_settings.dart';
import 'package:app_template/features/settings/domain/repositories/settings_repository.dart';
import 'package:app_template/features/settings/infrastructures/services/platform_settings_provider_impl.dart';
import 'package:data_domain_converters/data_domain_converters.dart';
import 'package:injectable/injectable.dart';
import 'package:preference_store/preference_store.dart';

@module
abstract class SettingsModule {
  DataDomainConverter<SettingsDTO, AppSettings> getSettingsMapper() {
    return SettingsMapper();
  }

  @singleton
  SettingsDataSource getSettingsDataSource(PreferenceStore preferenceStore) {
    return SettingsDataSourceImpl(preferenceStore);
  }

  @singleton
  PlatformSettingsProvider getPlatformSettingsProvider() {
    return PlatformSettingsProviderImpl();
  }

  @singleton
  SettingsRepository getSettingsRepository(
    DataDomainConverter<SettingsDTO, AppSettings> settingsMapper,
    SettingsDataSource settingsDataSource,
  ) {
    return SettingsRepositoryImpl(settingsMapper, settingsDataSource);
  }

  @singleton
  AppLocaleResolver getAppLocaleResolver() {
    return AppLocaleResolver();
  }

  @singleton
  SettingsService getSettingsService(
    AppLocaleResolver appLocaleResolver,
    PlatformSettingsProvider platformSettingsProvider,
    SettingsRepository settingsRepository,
  ) {
    return SettingsServiceImpl(
      appLocaleResolver,
      platformSettingsProvider,
      settingsRepository,
    );
  }
}
