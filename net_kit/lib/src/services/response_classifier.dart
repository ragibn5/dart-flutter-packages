import 'package:dio/dio.dart';

abstract interface class ResponseClassifier {
  /// Determines whether a [response] should be treated as an error.
  ///
  /// Defaults to `statusCode >= 400`, which is correct for well-behaved REST
  /// APIs. Override this for APIs that signal errors differently — for example,
  /// APIs that always return `200` with a `success` flag in the body:
  ///
  /// ```dart
  /// @override
  /// bool isError(Response<dynamic> response) {
  ///   final body = response.data as Map<String, dynamic>?;
  ///   return body?['success'] != true;
  /// }
  /// ```
  bool isError(Response<dynamic> response);
}

class DefaultResponseClassifier implements ResponseClassifier {
  const DefaultResponseClassifier();

  @override
  bool isError(Response<dynamic> response) => (response.statusCode ?? 0) >= 400;
}
