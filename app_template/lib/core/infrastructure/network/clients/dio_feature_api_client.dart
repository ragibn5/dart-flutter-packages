import 'package:app_template/core/infrastructure/network/clients/api_client.dart';
import 'package:app_template/core/infrastructure/network/error_mappers/dio_feature_api_error_mapper.dart';
import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/api_result.dart';
import 'package:app_template/core/models/dio_network_call_request.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

abstract class DioFeatureApiClient<
  RequestBodyType,
  ResponseBodyType,
  FeatureErrorType
>
    implements
        ApiClient<
          RequestBodyType,
          ResponseBodyType,
          ApiError<FeatureErrorType>
        > {
  final Dio _client;
  final DioFeatureApiErrorMapper<FeatureErrorType> _errorMapper;

  DioFeatureApiClient(this._client, this._errorMapper);

  @override
  Future<ApiResult<ApiError<FeatureErrorType>, ResponseBodyType>> request(
    RequestBodyType requestBody,
  ) async {
    try {
      final request = createRequest(requestBody);
      final rawResponse = await _client.request<dynamic>(
        request.pathOrUrl,
        data: request.data,
        queryParameters: request.queryParams,
        cancelToken: request.cancelToken,
        onSendProgress: request.onSendProgress,
        onReceiveProgress: request.onReceiveProgress,
      );
      return ApiResult.success(decodeResponse(rawResponse.data));
    } catch (e, st) {
      return ApiResult.failure(_errorMapper.mapError(e, st));
    }
  }

  @visibleForOverriding
  DioNetworkCallRequest createRequest(RequestBodyType body);

  @visibleForOverriding
  ResponseBodyType decodeResponse(dynamic responseData);
}
