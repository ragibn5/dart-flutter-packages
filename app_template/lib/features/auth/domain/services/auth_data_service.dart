import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/result.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';

abstract interface class AuthDataService {
  /// Get the cached [AuthData].
  ///
  /// Returns null if there is no cached [AuthData].
  Future<AuthData?> getCurrentAuthData();

  /// Set the [AuthData] to be cached.
  ///
  /// If [authData] is null, the cached [AuthData] (if any) will be removed.
  Future<void> setCurrentAuthData(AuthData? authData);

  /// Request an refreshed [AuthData] from the server and update the cache.
  ///
  /// Returns the newly refreshed [AuthData] if succeeded, or an instance of
  /// [ApiError<AuthDataRefreshError>] in case of failure. See the sub-types
  /// of [AuthDataRefreshError] for more details.
  Future<Result<ApiError<AuthDataRefreshError>, AuthData>>
  refreshCurrentAuthData();

  /// Watch for changes of the auth data.
  Stream<AuthData?> watchAuthData();
}
