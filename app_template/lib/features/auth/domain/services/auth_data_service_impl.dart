import 'dart:async';

import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/api_result.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';

class AuthDataServiceImpl implements AuthDataService {
  final AuthDataRepository _authRepository;

  AuthDataServiceImpl(this._authRepository);

  @override
  Future<AuthData?> getCurrentAuthData() {
    return _authRepository.getCurrentAuthData();
  }

  @override
  Future<void> setCurrentAuthData(AuthData? authData) {
    return _authRepository.setCurrentAuthData(authData);
  }

  @override
  Future<ApiResult<ApiError<AuthDataRefreshError>, AuthData>>
  refreshCurrentAuthData() async {
    final currentAuthData = await _authRepository.getCurrentAuthData();
    if (currentAuthData == null) {
      return ApiResult.failure(
        ApiError.fromServerError(InvalidAuthStateForRefresh()),
      );
    }

    final refreshedAuthData = await _authRepository.refreshCurrentAuthData(
      currentAuthData,
    );
    if (refreshedAuthData.isError) {
      return refreshedAuthData.errorOrNull!.fold(
        (ae) => ApiResult.failure(ApiError.fromAppError(ae)),
        (ne) => ApiResult.failure(ApiError.fromNetworkError(ne)),
        (se) => ApiResult.failure(ApiError.fromServerError(se)),
      );
    }

    return ApiResult.success(refreshedAuthData.dataOrNull!);
  }

  @override
  Stream<AuthData?> watchAuthData() {
    return _authRepository.getAuthDataStream();
  }
}
