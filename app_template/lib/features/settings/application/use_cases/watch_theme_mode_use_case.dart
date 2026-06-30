import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';
import 'package:app_template/features/settings/domain/repositories/settings_repository.dart';

class WatchThemeModeUseCase {
  final SettingsRepository _settingsRepository;

  WatchThemeModeUseCase(this._settingsRepository);

  /// Watch theme-mode selection changes.
  ///
  /// This emits a new value whenever the user changes the app-theme-mode,
  /// for example, by calling the [SetThemeModeUseCase].
  ///
  /// **Please note**: Do not call [SetThemeModeUseCase] in response to events
  /// received from the stream return by this method, as it will result
  /// in an infinite loop.
  Stream<AppThemeMode> call() {
    return _settingsRepository
        .getSettingsStream()
        .map((settings) => settings.themeMode ?? AppThemeMode.SYSTEM)
        .distinct();
  }
}
