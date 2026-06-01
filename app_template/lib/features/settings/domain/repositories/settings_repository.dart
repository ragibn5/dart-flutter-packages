import 'package:app_template/features/settings/domain/models/app_settings.dart';
import 'package:disposable/disposable.dart';

abstract interface class SettingsRepository implements Disposable {
  /// Get the current app settings.
  Future<AppSettings> getCurrentSettings();

  /// Set current app settings.
  Future<void> setCurrentSettings(AppSettings settings);

  /// Watch app settings change.
  Stream<AppSettings> getSettingsStream();
}
