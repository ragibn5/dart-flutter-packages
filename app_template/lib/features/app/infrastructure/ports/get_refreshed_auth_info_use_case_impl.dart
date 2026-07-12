import 'package:app_template/features/app/application/use_cases/get_refreshed_auth_info_use_case.dart';
import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/auth/application/use_cases/refresh_auth_data_use_case.dart';

class GetRefreshedAuthInfoUseCaseImpl implements GetRefreshedAuthInfoUseCase {
  final RefreshAuthDataUseCase _getRefreshAuthData;

  GetRefreshedAuthInfoUseCaseImpl(this._getRefreshAuthData);

  @override
  Future<AuthInfo?> call() async {
    final result = await _getRefreshAuthData();
    if (result.isLeft) {
      return null;
    }

    final response = result.rightOrThrow;
    if (response.isLeft) {
      return null;
    }

    final refreshedAuthData = response.rightOrThrow;
    return AuthInfo(
      accessToken: refreshedAuthData.accessToken,
      refreshToken: refreshedAuthData.refreshToken,
      accessTokenExpiry: refreshedAuthData.accessTokenExpiry,
      refreshTokenExpiry: refreshedAuthData.refreshTokenExpiry,
    );
  }
}
