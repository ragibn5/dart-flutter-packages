import 'package:app_template/core/models/dio_network_call_request.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

class AppServerTokenRefreshApiClientImpl
    extends AppServerTokenRefreshApiClient {
  @visibleForTesting
  static const path = 'refresh-token';

  AppServerTokenRefreshApiClientImpl(super.client, super.errorMapper);

  @override
  DioNetworkCallRequest createRequest(TokenRefreshRequest body) {
    return DioNetworkCallRequest(
      pathOrUrl: path,
      data: body.toJson(),
      options: Options(method: 'GET'),
    );
  }

  @override
  AuthDataDTO decodeResponse(dynamic responseData) {
    return AuthDataDTO.fromJson(responseData as Map<String, dynamic>);
  }
}
