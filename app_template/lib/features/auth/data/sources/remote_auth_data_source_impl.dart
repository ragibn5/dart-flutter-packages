import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client.dart';
import 'package:core_models/core_models.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: RemoteAuthDataSource)
class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  final AppServerTokenRefreshApiClient _client;

  RemoteAuthDataSourceImpl(this._client);

  @override
  Future<Either<ApiError, Either<ServerMessage, AuthDataDTO>>>
  getRefreshedAuthData(TokenRefreshRequest tokenRefreshRequest) async {
    final r = await _client.request(tokenRefreshRequest);
    return r.fold(onLeft: Left.new, onRight: (r) => Right(r.toEither()));
  }
}
