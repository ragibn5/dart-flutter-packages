import 'package:app_template/features/app/application/use_cases/watch_locale_use_case.dart';
import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';

class SetLocaleUseCase {
  final SettingsRepository _settingsRepository;

  SetLocaleUseCase(this._settingsRepository);

  /// Persists the user-selected app locale.
  ///
  /// This call will also add the [locale] to any stream obtained from
  /// [WatchLocaleUseCase].
  Future<void> call(AppLocale locale) async {
    final persistedSettings = await _settingsRepository.getCurrentSettings();
    await _settingsRepository.setCurrentSettings(
      persistedSettings.copyWith(locale: locale),
    );
  }
}
