import 'package:app_template/features/app/application/use_cases/get_user_id_use_case.dart';
import 'package:app_template/features/auth/application/use_cases/get_auth_data_use_case.dart';

class GetUserIdUseCaseImpl implements GetUserIdUseCase {
  final GetAuthDataUseCase _getAuthDataUseCase;

  GetUserIdUseCaseImpl(this._getAuthDataUseCase);

  @override
  Future<String?> call() async {
    return (await _getAuthDataUseCase.call())?.userId;
  }
}
