import 'package:app_template/features/user_data/data/models/user_data_dto.dart';

abstract interface class UserDataDataSource {
  Future<UserDataDTO?> getUserData(String userId);

  Future<void> setUserData(UserDataDTO entity);

  Future<void> removeUserData(String userId);
}
