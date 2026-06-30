import 'package:app_template/features/app/application/use_cases/get_effective_theme_mode_use_case.dart';
import 'package:app_template/features/settings/application/use_cases/get_effective_theme_mode_use_case.dart'
    as settings;
import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';

class GetEffectiveThemeModeUseCaseImpl implements GetEffectiveThemeModeUseCase {
  final settings.GetEffectiveThemeModeUseCase _getEffectiveThemeMode;

  GetEffectiveThemeModeUseCaseImpl(this._getEffectiveThemeMode);

  @override
  Future<AppThemeMode> call() {
    return _getEffectiveThemeMode();
  }
}
