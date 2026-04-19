import 'package:app_template/core/models/result.dart';

abstract interface class ApiClient<
  RequestBodyType,
  ResponseBodyType,
  ErrorType
> {
  Future<Result<ErrorType, ResponseBodyType>> request(
    RequestBodyType requestBody,
  );
}
