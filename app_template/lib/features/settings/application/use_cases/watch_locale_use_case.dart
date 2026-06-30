import 'package:app_template/features/app/application/use_cases/set_locale_use_case.dart';
import 'package:app_template/features/settings/application/use_cases/get_platform_locale_use_case.dart';
import 'package:app_template/features/settings/domain/entities/app_locale.dart';
import 'package:app_template/features/settings/domain/repositories/settings_repository.dart';
import 'package:app_template/features/settings/domain/services/app_locale_resolver.dart';

class WatchLocaleUseCase {
  final SettingsRepository _settingsRepository;

  final AppLocaleResolver _appLocaleResolver;

  final GetPlatformLocaleUseCase _getPlatformLocale;

  WatchLocaleUseCase(
    this._settingsRepository,
    this._getPlatformLocale,
    this._appLocaleResolver,
  );

  /// Watch locale selection changes.
  ///
  /// This emits a new value whenever the user changes the app-locale,
  /// specifically, by calling the [SetLocaleUseCase].
  ///
  /// **Please note**: Do not call [SetLocaleUseCase] in response to events
  /// received from the stream return by this method, as it will result
  /// in an infinite loop.
  Stream<AppLocale> call() {
    return _settingsRepository
        .getSettingsStream()
        .asyncMap(
          (settings) async => settings.locale ?? await _resolvePlatformLocale(),
        )
        .distinct();
  }

  Future<AppLocale> _resolvePlatformLocale() async {
    final platformLocale = await _getPlatformLocale();
    return _appLocaleResolver.resolveLocale(platformLocale) ?? AppLocale.EN;
  }
}
