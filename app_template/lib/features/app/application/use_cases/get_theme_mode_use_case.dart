import 'package:app_template/features/app/domain/entities/app_theme_mode.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';

class GetThemeModeUseCase {
  final SettingsRepository _settingsRepository;

  GetThemeModeUseCase(this._settingsRepository);

  /// Returns the current app theme mode.
  Future<AppThemeMode> call() async {
    final persistedSettings = await _settingsRepository.getCurrentSettings();
    return persistedSettings.themeMode ?? AppThemeMode.SYSTEM;
  }
}
