import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/result.dart';
import 'package:app_template/core/models/server_message.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: RemoteAuthDataSource)
class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  final AppServerTokenRefreshApiClient _appServerTokenRefreshApiClient;

  RemoteAuthDataSourceImpl(this._appServerTokenRefreshApiClient);

  @override
  Future<Result<ApiError<ServerError<ServerMessage>>, AuthDataDTO>>
  getRefreshedAuthData(TokenRefreshRequest tokenRefreshRequest) {
    return _appServerTokenRefreshApiClient.request(tokenRefreshRequest);
  }
}
