import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';

class GetEffectiveThemeModeUseCase {
  final SettingsRepository _settingsRepository;

  GetEffectiveThemeModeUseCase(this._settingsRepository);

  Future<AppThemeMode> call() async {
    final settings = await _settingsRepository.getCurrentSettings();
    return settings.themeMode;
  }
}
