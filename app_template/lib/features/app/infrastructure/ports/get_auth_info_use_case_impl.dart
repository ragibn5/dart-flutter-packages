import 'package:app_template/features/app/application/use_cases/get_auth_info_use_case.dart';
import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/auth/application/use_cases/get_auth_data_use_case.dart';

class GetAuthInfoUseCaseImpl implements GetAuthInfoUseCase {
  final GetAuthDataUseCase _getAuthData;

  GetAuthInfoUseCaseImpl(this._getAuthData);

  @override
  Future<AuthInfo?> call() async {
    final authData = await _getAuthData();
    if (authData == null) {
      return null;
    }

    return AuthInfo(
      accessToken: authData.accessToken,
      refreshToken: authData.refreshToken,
      accessTokenExpiry: authData.accessTokenExpiry,
      refreshTokenExpiry: authData.refreshTokenExpiry,
    );
  }
}
