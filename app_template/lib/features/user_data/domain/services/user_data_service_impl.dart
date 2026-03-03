import 'dart:async';

import 'package:app_template/features/user_data/domain/models/user_data.dart';
import 'package:app_template/features/user_data/domain/repositories/user_data_repository.dart';
import 'package:app_template/features/user_data/domain/services/user_data_service.dart';

class UserDataServiceImpl implements UserDataService {
  final UserDataRepository _userDataRepository;

  UserDataServiceImpl(this._userDataRepository);

  @override
  Future<UserData?> getUserData(String userId) {
    return _userDataRepository.getUserData(userId);
  }

  @override
  Future<void> setUserData(UserData data) {
    return _userDataRepository.setUserData(data);
  }

  @override
  Future<void> removeUserData(String userId) {
    return _userDataRepository.removeUserData(userId);
  }
}
