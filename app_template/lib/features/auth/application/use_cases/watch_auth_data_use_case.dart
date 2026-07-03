import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';

class WatchAuthDataUseCase {
  final AuthDataRepository _authRepository;

  WatchAuthDataUseCase(this._authRepository);

  /// Watch for changes of the auth data.
  Stream<AuthData?> call() {
    return _authRepository.getAuthDataStream();
  }
}
