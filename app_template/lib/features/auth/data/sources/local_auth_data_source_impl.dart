import 'dart:convert';

import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/sources/local_auth_data_source.dart';
import 'package:meta/meta.dart';
import 'package:preference_store/preference_store.dart';

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  @visibleForTesting
  static const String preferenceKey = 'auth_data';

  final PreferenceStore _preferenceStore;

  LocalAuthDataSourceImpl(this._preferenceStore);

  @override
  Future<AuthDataDTO?> getCurrentAuthData() async {
    final authDataJson = await _preferenceStore.getString(preferenceKey);
    if (authDataJson == null) {
      return null;
    }

    return AuthDataDTO.fromJson(
      jsonDecode(authDataJson) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> setCurrentAuthData(AuthDataDTO? authData) async {
    final authDataJson = authData != null
        ? jsonEncode(authData.toJson())
        : null;

    if (authDataJson == null) {
      await _preferenceStore.remove(preferenceKey);
      return;
    }

    await _preferenceStore.setString(preferenceKey, authDataJson);
  }
}
