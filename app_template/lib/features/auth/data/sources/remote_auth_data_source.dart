import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/api_result.dart';
import 'package:app_template/core/models/server_message.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';

abstract interface class RemoteAuthDataSource {
  Future<ApiResult<ApiError<ServerError<ServerMessage>>, AuthDataDTO>>
  getRefreshedAuthData(TokenRefreshRequest tokenRefreshRequest);
}
