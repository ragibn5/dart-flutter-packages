import 'package:app_template/features/auth/data/models/auth_data_dto.dart';

abstract interface class LocalAuthDataSource {
  Future<AuthDataDTO?> getCurrentAuthData();

  Future<void> setCurrentAuthData(AuthDataDTO? authData);
}
