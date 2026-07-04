import 'package:app_template/features/app/application/use_cases/set_settings_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_settings_use_case.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';

class WatchThemeModeUseCase {
  final WatchSettingsUseCase _watchSettings;

  WatchThemeModeUseCase(this._watchSettings);

  /// Watch theme-mode selection changes.
  ///
  /// This emits a new value whenever the user changes the app-theme-mode,
  /// for example, by calling the [SetSettingsUseCase].
  ///
  /// **Please note**: Do not call [SetSettingsUseCase] in response to events
  /// received from the stream return by this method, as it will result in an
  /// infinite loop.
  Stream<AppThemeMode> call() {
    return _watchSettings().map((settings) => settings.themeMode).distinct();
  }
}
