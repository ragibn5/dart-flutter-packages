import 'package:app_template/features/app/application/use_cases/get_settings_use_case.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';

class GetEffectiveThemeModeUseCase {
  final GetSettingsUseCase _getSettings;

  GetEffectiveThemeModeUseCase(this._getSettings);

  Future<AppThemeMode> call() async {
    final settings = await _getSettings();
    return settings.themeMode;
  }
}
