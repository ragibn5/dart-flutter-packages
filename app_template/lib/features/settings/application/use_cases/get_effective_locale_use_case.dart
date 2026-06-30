import 'package:app_template/features/settings/application/use_cases/get_platform_locale_use_case.dart';
import 'package:app_template/features/settings/domain/entities/app_locale.dart';
import 'package:app_template/features/settings/domain/repositories/settings_repository.dart';
import 'package:app_template/features/settings/domain/services/app_locale_resolver.dart';

class GetEffectiveLocaleUseCase {
  final SettingsRepository _settingsRepository;
  final GetPlatformLocaleUseCase _getPlatformLocale;
  final AppLocaleResolver _appLocaleResolver;

  GetEffectiveLocaleUseCase(
    this._settingsRepository,
    this._getPlatformLocale,
    this._appLocaleResolver,
  );

  /// Returns the **effective app locale**.
  ///
  /// Resolution order:
  /// 1. If the user explicitly selected a locale earlier, it is returned.
  /// 2. Otherwise, if the system's current locale can be mapped into
  ///    one of the supported locales (i.e. [AppLocale.values]), then
  ///    that is returned.
  /// 3. If none of the above works out, [AppLocale.EN] is returned.
  ///
  /// NOTE: This method does not persist any values.
  Future<AppLocale> call() async {
    final persistedSettings = await _settingsRepository.getCurrentSettings();
    if (persistedSettings.locale != null) {
      return persistedSettings.locale!;
    }

    return _resolvePlatformLocale();
  }

  Future<AppLocale> _resolvePlatformLocale() async {
    final platformLocale = await _getPlatformLocale();
    return _appLocaleResolver.resolveLocale(platformLocale) ?? AppLocale.EN;
  }
}
