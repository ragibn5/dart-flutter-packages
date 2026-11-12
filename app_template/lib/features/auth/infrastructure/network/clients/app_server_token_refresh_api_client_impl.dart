import 'package:app_template/features/auth/data/clients/app_server_token_refresh_api_client.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:net_models/net_models.dart';
import 'package:shared_models/shared_models.dart';

class AppServerTokenRefreshApiClientImpl
    extends AppServerTokenRefreshApiClient {
  @visibleForTesting
  static const path = 'refresh-token';

  AppServerTokenRefreshApiClientImpl(super.client);

  @override
  Future<Response<Object?>> send(Dio dio, TokenRefreshRequest body) {
    return dio.get<Object?>(path, data: body.toJson());
  }

  @override
  ApiResponse<ServerMessage, AuthDataDTO> decodeResponse(
    Response<Object?> response,
  ) {
    final statusCode = response.statusCode!;
    final json = response.data! as Map<String, dynamic>;
    if (statusCode >= 400) {
      return FailureResponse(
        error: ServerMessage.fromJson(json),
        statusCode: statusCode,
        headers: response.headers.map,
      );
    }

    return SuccessResponse(
      data: AuthDataDTO.fromJson(json),
      statusCode: statusCode,
      headers: response.headers.map,
    );
  }
}
