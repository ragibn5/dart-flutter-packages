import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';
import 'package:app_template/features/settings/domain/repositories/settings_repository.dart';

class GetEffectiveThemeModeUseCase {
  final SettingsRepository _settingsRepository;

  GetEffectiveThemeModeUseCase(this._settingsRepository);

  /// Returns the **effective app theme mode**.
  ///
  /// Resolution order:
  /// 1. If the user explicitly selected a theme-mode earlier, it is returned.
  /// 2. Otherwise, [AppThemeMode.SYSTEM] is returned.
  ///
  /// NOTE: This method does not persist any value.
  Future<AppThemeMode> call() async {
    final persistedSettings = await _settingsRepository.getCurrentSettings();
    return persistedSettings.themeMode ?? AppThemeMode.SYSTEM;
  }
}
