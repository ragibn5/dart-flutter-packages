import 'package:app_template/core/infrastructure/network/error_mappers/dio_feature_api_error_mapper.dart';
import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/server_message.dart';

class AppServerTokenRefreshApiErrorMapper
    extends DioFeatureApiErrorMapper<ServerError<ServerMessage>> {
  @override
  ApiError<ServerError<ServerMessage>> mapServerError(
    int? statusCode,
    dynamic errorResponseBody,
  ) {
    return ApiError.fromServerError(
      ServerError(
        statusCode: statusCode ?? 0,
        errorResponse: ServerMessage.fromJson(
          errorResponseBody as Map<String, dynamic>,
        ),
      ),
    );
  }
}
