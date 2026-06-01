import 'package:app_template/core/models/api_response.dart';
import 'package:app_template/core/models/server_message.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/net_kit.dart';

class AppServerTokenRefreshApiClientImpl
    extends AppServerTokenRefreshApiClient {
  @visibleForTesting
  static const path = 'refresh-token';

  AppServerTokenRefreshApiClientImpl(super.client);

  @override
  RequestSpec createRequest(TokenRefreshRequest body) {
    return RequestSpec(
      pathOrUrl: path,
      method: HttpMethod.GET,
      body: JsonBody(body.toJson()),
    );
  }

  @override
  ApiResponse<ServerMessage, AuthDataDTO> decodeResponse(
    NetKitResponse response,
  ) {
    if (response.isError) {
      return Failure(
        error: ServerMessage.fromJson(response.data! as Map<String, dynamic>),
        statusCode: response.statusCode,
        headers: response.headers,
      );
    }

    return Success(
      data: AuthDataDTO.fromJson(response.data! as Map<String, dynamic>),
      statusCode: response.statusCode,
      headers: response.headers,
    );
  }
}
