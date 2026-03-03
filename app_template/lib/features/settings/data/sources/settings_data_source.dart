import 'package:app_template/features/settings/data/models/settings_dto.dart';

abstract interface class SettingsDataSource {
  Future<SettingsDTO> getCurrentSettings();

  Future<void> setCurrentSettings(SettingsDTO settings);
}
