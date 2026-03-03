import 'package:app_template/core/models/api_result.dart';

abstract interface class ApiClient<
  RequestBodyType,
  ResponseBodyType,
  ErrorType
> {
  Future<ApiResult<ErrorType, ResponseBodyType>> request(
    RequestBodyType requestBody,
  );
}
