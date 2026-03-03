import 'package:app_template/features/settings/domain/repositories/settings_repository.dart';
import 'package:app_template/features/settings/domain/services/app_locale_resolver.dart';
import 'package:app_template/features/settings/domain/services/app_locale_resolver_impl.dart';
import 'package:app_template/features/settings/domain/services/platform_settings_provider.dart';
import 'package:app_template/features/settings/domain/services/settings_service.dart';
import 'package:app_template/features/settings/domain/services/settings_service_impl.dart';
import 'package:injectable/injectable.dart';

@module
abstract class SettingsModule {
  @singleton
  AppLocaleResolver getAppLocaleResolver() {
    return AppLocaleResolverImpl();
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
