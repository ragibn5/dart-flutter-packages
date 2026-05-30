import 'package:app_template/features/settings/data/models/settings_dto.dart';

abstract interface class SettingsDataSource {
  /// Get the persisted settings, or null if not available.
  Future<SettingsDTO?> getCurrentSettings();

  /// Persist the given settings.
  Future<void> setCurrentSettings(SettingsDTO settings);
}
