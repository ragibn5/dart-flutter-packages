import 'package:app_template/features/auth/domain/entities/auth_data.dart';
import 'package:app_template/features/auth/domain/entities/auth_data_refresh_error.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:core_models/core_models.dart';

abstract interface class RefreshAuthDataUseCase {
  final AuthDataRepository _authRepository;

  RefreshAuthDataUseCase(this._authRepository);

  /// Request an refreshed [AuthData] from the server and update the cache.
  ///
  /// Returns the newly refreshed [AuthData] if succeeded, or an instance of
  /// [ApiError<AuthDataRefreshError>] in case of failure. See the sub-types
  /// of [AuthDataRefreshError] for more details.
  Future<Either<ApiError, Either<AuthDataRefreshError, AuthData>>>
  call() async {
    final currentAuthData = await _authRepository.getCurrentAuthData();
    if (currentAuthData == null) {
      return Right(Left(InvalidAuthStateForRefresh()));
    }

    return _authRepository.refreshCurrentAuthData(currentAuthData);
  }
}
