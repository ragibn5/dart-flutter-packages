import 'package:app_template/features/auth/domain/entities/auth_data.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';

abstract interface class GetAuthDataUseCase {
  final AuthDataRepository _authRepository;

  GetAuthDataUseCase(this._authRepository);

  /// Get the cached [AuthData].
  ///
  /// Returns null if there is no cached [AuthData].
  Future<AuthData?> call() {
    return _authRepository.getCurrentAuthData();
  }
}
