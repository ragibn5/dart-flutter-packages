import 'dart:convert';

import 'package:app_template/features/settings/data/models/settings_dto.dart';
import 'package:app_template/features/settings/data/sources/settings_data_source.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:preference_store/preference_store.dart';

@Injectable(as: SettingsDataSource)
class SettingsDataSourceImpl implements SettingsDataSource {
  @visibleForTesting
  static const String preferenceKey = 'app_preferences';

  final PreferenceStore _preferenceStore;

  SettingsDataSourceImpl(this._preferenceStore);

  @override
  Future<SettingsDTO?> getCurrentSettings() async {
    final settingJson = await _preferenceStore.getString(preferenceKey);

    if (settingJson == null) {
      return null;
    }

    return SettingsDTO.fromJson(
      jsonDecode(settingJson) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> setCurrentSettings(SettingsDTO settings) {
    return _preferenceStore.setString(
      preferenceKey,
      jsonEncode(settings.toJson()),
    );
  }
}
