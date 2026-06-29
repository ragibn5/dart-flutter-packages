import 'package:app_template/features/app/application/use_cases/get_effective_theme_mode_use_case.dart';
import 'package:app_template/features/settings/application/services/settings_service.dart';
import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';

class GetEffectiveThemeModeUseCaseImpl implements GetEffectiveThemeModeUseCase {
  final SettingsService _settingsService;

  GetEffectiveThemeModeUseCaseImpl(this._settingsService);

  @override
  Future<AppThemeMode> call() {
    return _settingsService.getEffectiveThemeMode();
  }
}
