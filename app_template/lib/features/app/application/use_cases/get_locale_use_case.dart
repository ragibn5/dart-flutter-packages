import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';

class GetLocaleUseCase {
  final SettingsRepository _settingsRepository;

  GetLocaleUseCase(this._settingsRepository);

  /// Returns the current locale.
  Future<AppLocale> call() async {
    final persistedSettings = await _settingsRepository.getCurrentSettings();
    return persistedSettings.locale ?? AppLocale.SYSTEM;
  }
}
