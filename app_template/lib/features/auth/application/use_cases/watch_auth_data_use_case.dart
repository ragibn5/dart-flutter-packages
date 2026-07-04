import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';

/// Watch for changes of the auth data.
class WatchAuthDataUseCase {
  final AuthDataRepository _authRepository;

  WatchAuthDataUseCase(this._authRepository);

  Stream<AuthData?> call() {
    return _authRepository.getAuthDataStream().distinct();
  }
}
