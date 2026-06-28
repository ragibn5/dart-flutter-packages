import 'package:app_template/features/auth/domain/entities/auth_data.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';

abstract interface class WatchAuthDataUseCase {
  final AuthDataRepository _authRepository;

  WatchAuthDataUseCase(this._authRepository);

  /// Watch for changes of the auth data.
  Stream<AuthData?> call() {
    return _authRepository.getAuthDataStream();
  }
}
