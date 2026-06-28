import 'package:app_template/features/auth/domain/entities/auth_data.dart';
import 'package:app_template/features/auth/domain/entities/auth_data_refresh_error.dart';
import 'package:core_models/core_models.dart';

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
  Future<Either<ApiError, Either<AuthDataRefreshError, AuthData>>>
  refreshCurrentAuthData();

  /// Watch for changes of the auth data.
  Stream<AuthData?> watchAuthData();
}
