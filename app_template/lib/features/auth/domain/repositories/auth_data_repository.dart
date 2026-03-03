import 'package:app_template/core/contracts/disposable.dart';
import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/api_result.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';

abstract interface class AuthDataRepository implements Disposable {
  Stream<AuthData?> getAuthDataStream();

  Future<AuthData?> getCurrentAuthData();

  Future<ApiResult<ApiError<AuthDataRefreshError>, AuthData>>
  refreshCurrentAuthData(AuthData authData);

  Future<void> setCurrentAuthData(AuthData? authData);
}
