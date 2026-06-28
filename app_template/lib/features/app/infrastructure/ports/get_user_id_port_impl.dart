import 'package:app_template/features/app/application/ports/get_user_id_port.dart';
import 'package:app_template/features/auth/application/use_cases/get_auth_data_use_case.dart';

class GetUserIdPortImpl implements GetUserIdPort {
  final GetAuthDataUseCase _getAuthDataUseCase;

  GetUserIdPortImpl(this._getAuthDataUseCase);

  @override
  Future<String?> call() async {
    return (await _getAuthDataUseCase.call())?.userId;
  }
}
