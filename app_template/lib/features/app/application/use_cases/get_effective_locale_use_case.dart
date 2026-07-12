import 'package:app_template/features/app/application/use_cases/get_platform_locale_use_case.dart';
import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:app_template/features/app/domain/services/app_locale_resolver.dart';

/// Returns the **effective app locale** as [LocaleComponents].
///
/// Resolution order:
/// 1. If the user explicitly selected a locale earlier, its corresponding
///    locale components are returned.
/// 2. Otherwise, if the system's current locale can be mapped into
///    one of the supported locales (i.e. [AppLocale.values]), then
///    its corresponding locale components are returned.
/// 3. If none of the above works out, [AppLocale.EN]'s corresponding
///    locale components are returned.
class GetEffectiveLocaleUseCase {
  final SettingsRepository _settingsRepository;

  final AppLocaleResolver _appLocaleResolver;

  final GetPlatformLocaleUseCase _getPlatformLocale;

  GetEffectiveLocaleUseCase(
    this._settingsRepository,
    this._appLocaleResolver,
    this._getPlatformLocale,
  );

  Future<LocaleComponents> call() async {
    final settings = await _settingsRepository.getCurrentSettings();
    if (settings.locale != AppLocale.SYSTEM) {
      return _mapToLocaleComponents(settings.locale);
    }

    final platformLocale = await _getPlatformLocale();
    final resolvedLocale = _appLocaleResolver.resolverAppLocale(platformLocale);
    return _mapToLocaleComponents(resolvedLocale ?? AppLocale.EN);
  }

  LocaleComponents _mapToLocaleComponents(AppLocale locale) {
    return LocaleComponents(
      languageCode: locale.languageCode,
      scriptCode: locale.scriptCode,
      countryCode: locale.countryCode,
    );
  }
}
