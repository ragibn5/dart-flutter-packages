import 'dart:async';

import 'package:app_template/features/user_data/data/models/user_data_dto.dart';
import 'package:app_template/features/user_data/data/sources/user_data_data_source.dart';
import 'package:app_template/features/user_data/domain/models/user_data.dart';
import 'package:app_template/features/user_data/domain/repositories/user_data_repository.dart';
import 'package:data_domain_converters/data_domain_converters.dart';

class UserDataRepositoryImpl implements UserDataRepository {
  final DataDomainConverter<UserDataDTO, UserData> _userDataMapper;
  final UserDataDataSource _userDataDataSource;

  UserDataRepositoryImpl(
    DataDomainConverter<UserDataDTO, UserData> userDataMapper,
    UserDataDataSource userDataDataSource,
  ) : _userDataMapper = userDataMapper,
      _userDataDataSource = userDataDataSource;

  @override
  Future<UserData?> getUserData(String userId) async {
    final entity = await _userDataDataSource.getUserData(userId);
    if (entity == null) {
      return null;
    }

    return _userDataMapper.convertDataToDomain(entity);
  }

  @override
  Future<void> setUserData(UserData data) async {
    return _userDataDataSource.setUserData(
      _userDataMapper.convertDomainToData(data),
    );
  }

  @override
  Future<void> removeUserData(String userId) {
    return _userDataDataSource.removeUserData(userId);
  }
}
