import 'package:app_template/features/auth/domain/entities/auth_data.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';

class SetAuthDataUseCase {
  final AuthDataRepository _authRepository;

  SetAuthDataUseCase(this._authRepository);

  /// Set the [AuthData] to be cached.
  ///
  /// If [authData] is null, the cached [AuthData] (if any) will be removed.
  Future<void> call(AuthData? authData) {
    return _authRepository.setCurrentAuthData(authData);
  }
}
