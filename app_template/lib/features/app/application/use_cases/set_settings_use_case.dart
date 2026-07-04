import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';

class SetSettingsUseCase {
  final SettingsRepository _settingsRepository;

  SetSettingsUseCase(this._settingsRepository);

  Future<void> call(AppSettings settings) =>
      _settingsRepository.setCurrentSettings(settings);
}
