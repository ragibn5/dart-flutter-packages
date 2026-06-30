import 'package:app_template/features/app/application/use_cases/set_theme_mode_use_case.dart';
import 'package:app_template/features/settings/application/use_cases/set_theme_mode_use_case.dart'
    as settings;
import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';

class SetThemeModeUseCaseImpl implements SetThemeModeUseCase {
  final settings.SetThemeModeUseCase _setThemeMode;

  SetThemeModeUseCaseImpl(this._setThemeMode);

  @override
  Future<void> call(AppThemeMode themeMode) {
    return _setThemeMode(themeMode);
  }
}
