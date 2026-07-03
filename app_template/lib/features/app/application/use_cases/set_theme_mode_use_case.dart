import 'package:app_template/features/app/application/use_cases/watch_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';

class SetThemeModeUseCase {
  final SettingsRepository _settingsRepository;

  SetThemeModeUseCase(this._settingsRepository);

  /// Persists the user-selected app theme mode.
  ///
  /// This call will also add the [themeMode] to any stream obtained from
  /// [WatchThemeModeUseCase].
  Future<void> call(AppThemeMode themeMode) async {
    final persistedSettings = await _settingsRepository.getCurrentSettings();
    await _settingsRepository.setCurrentSettings(
      persistedSettings.copyWith(themeMode: themeMode),
    );
  }
}
