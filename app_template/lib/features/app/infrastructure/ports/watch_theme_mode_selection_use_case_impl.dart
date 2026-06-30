import 'package:app_template/features/app/application/use_cases/watch_theme_mode_selection_use_case.dart';
import 'package:app_template/features/settings/application/use_cases/watch_theme_mode_use_case.dart'
    as settings;
import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';

class WatchThemeModeSelectionUseCaseImpl
    implements WatchThemeModeSelectionUseCase {
  final settings.WatchThemeModeUseCase _watchThemeMode;

  WatchThemeModeSelectionUseCaseImpl(this._watchThemeMode);

  @override
  Stream<AppThemeMode> call() {
    return _watchThemeMode();
  }
}
