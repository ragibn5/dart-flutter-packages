import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:core_models/core_models.dart';
import 'package:functionals/functionals.dart';

/// Request an refreshed [AuthData] from the server and update the cache.
///
/// Returns the newly refreshed [AuthData] if succeeded, or an instance of
/// [ApiError<AuthDataRefreshError>] in case of failure. See the sub-types
/// of [AuthDataRefreshError] for more details.
class RefreshAuthDataUseCase {
  final AuthDataRepository _authRepository;

  RefreshAuthDataUseCase(this._authRepository);

  Future<Either<ApiError, Either<AuthDataRefreshError, AuthData>>>
  call() async {
    final currentAuthData = await _authRepository.getCurrentAuthData();
    if (currentAuthData == null) {
      return Right(Left(InvalidAuthStateForRefresh()));
    }

    return _authRepository.refreshCurrentAuthData(currentAuthData);
  }
}
