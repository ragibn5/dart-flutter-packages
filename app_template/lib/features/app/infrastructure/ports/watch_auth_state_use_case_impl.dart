import 'package:app_template/features/app/application/use_cases/watch_auth_state_use_case.dart';
import 'package:app_template/features/auth/application/use_cases/watch_auth_data_use_case.dart';

class WatchAuthStateUseCaseImpl implements WatchAuthStateUseCase {
  final WatchAuthDataUseCase _watchAuthData;

  WatchAuthStateUseCaseImpl(this._watchAuthData);

  @override
  Stream<bool> call() {
    return _watchAuthData().map((authData) => authData != null);
  }
}
