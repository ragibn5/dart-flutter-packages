import 'dart:async';

import 'package:app_template/features/user_data/domain/models/user_data.dart';

abstract interface class UserDataRepository {
  Future<UserData?> getUserData(String userId);

  Future<void> setUserData(UserData data);

  Future<void> removeUserData(String userId);
}
