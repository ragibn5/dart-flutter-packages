import 'package:dio/dio.dart';

abstract interface class ResponseClassifier {
  /// Determines whether a [response] should be treated as an error.
  bool isError(Response<dynamic> response);
}

class DefaultResponseClassifier implements ResponseClassifier {
  const DefaultResponseClassifier();

  @override
  bool isError(Response<dynamic> response) => (response.statusCode ?? 0) >= 400;
}
