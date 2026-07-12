import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';

/// Get the cached [AuthData].
///
/// Returns null if there is no cached [AuthData].
class GetAuthDataUseCase {
  final AuthDataRepository _authRepository;

  GetAuthDataUseCase(this._authRepository);

  Future<AuthData?> call() {
    return _authRepository.getCurrentAuthData();
  }
}
