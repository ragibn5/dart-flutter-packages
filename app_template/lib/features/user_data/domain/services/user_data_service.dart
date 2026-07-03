import 'dart:async';

import 'package:app_template/features/user_data/domain/models/user_data.dart';

abstract interface class UserDataService {
  /// Get user data for the given user id.
  ///
  /// Returns null if no data is found.
  Future<UserData?> getUserData(String userId);

  /// Set user data for the given user id.
  ///
  /// If the user data already exists, it will be updated.
  Future<void> setUserData(UserData data);

  /// Remove user data for the given user id.
  ///
  /// If the user data does not exist, this method will do nothing.
  Future<void> removeUserData(String userId);
}
