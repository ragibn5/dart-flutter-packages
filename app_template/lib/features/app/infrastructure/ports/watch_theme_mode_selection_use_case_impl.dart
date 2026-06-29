import 'package:app_template/features/app/application/use_cases/watch_theme_mode_selection_use_case.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';

class WatchThemeModeSelectionUseCaseImpl
    implements WatchThemeModeSelectionUseCase {
  final SettingsService _settingsService;

  WatchThemeModeSelectionUseCaseImpl(this._settingsService);

  @override
  Stream<AppThemeMode> call() {
    return _settingsService.watchThemeMode();
  }
}
