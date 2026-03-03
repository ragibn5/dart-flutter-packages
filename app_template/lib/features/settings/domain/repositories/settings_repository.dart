import 'package:app_template/core/contracts/disposable.dart';
import 'package:app_template/features/settings/domain/models/app_settings.dart';

abstract interface class SettingsRepository implements Disposable {
  Future<AppSettings> getCurrentSettings();

  Future<void> setCurrentSettings(AppSettings settings);

  Stream<AppSettings> getSettingsStream();
}
