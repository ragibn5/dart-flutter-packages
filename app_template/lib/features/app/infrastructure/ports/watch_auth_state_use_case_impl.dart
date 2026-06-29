import 'package:app_template/features/app/application/use_cases/watch_auth_state_use_case.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';

class WatchAuthStateUseCaseImpl implements WatchAuthStateUseCase {
  final AuthDataService _authDataService;

  WatchAuthStateUseCaseImpl(this._authDataService);

  @override
  Stream<bool> call() {
    return _authDataService.watchAuthData().map((authData) => authData != null);
  }
}
