import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:core_models/core_models.dart';
import 'package:functionals/functionals.dart';
import 'package:shared_models/shared_models.dart';

abstract interface class RemoteAuthDataSource {
  Future<Either<ApiError, Either<ServerMessage, AuthDataDTO>>>
  getRefreshedAuthData(TokenRefreshRequest tokenRefreshRequest);
}
