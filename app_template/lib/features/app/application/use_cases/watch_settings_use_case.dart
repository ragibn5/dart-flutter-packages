import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';

class WatchSettingsUseCase {
  final SettingsRepository _settingsRepository;

  WatchSettingsUseCase(this._settingsRepository);

  Stream<AppSettings> call() => _settingsRepository.getSettingsStream().distinct();
}
