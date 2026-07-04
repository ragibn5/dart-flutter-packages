import 'package:app_template/features/app/application/use_cases/get_auth_state_use_case.dart';
import 'package:app_template/features/auth/application/use_cases/get_auth_data_use_case.dart';

class GetAuthStateUseCaseImpl implements GetAuthStateUseCase {
  final GetAuthDataUseCase _getAuthData;

  GetAuthStateUseCaseImpl(this._getAuthData);

  @override
  Future<bool> call() async {
    final authData = await _getAuthData();
    return (authData == null);
  }
}
