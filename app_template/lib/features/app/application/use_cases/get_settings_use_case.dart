import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository _settingsRepository;

  GetSettingsUseCase(this._settingsRepository);

  Future<AppSettings> call() => _settingsRepository.getCurrentSettings();
}
