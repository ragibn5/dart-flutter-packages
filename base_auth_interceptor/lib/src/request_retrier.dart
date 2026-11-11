import 'package:dio/dio.dart';

/// Sends a request again on behalf of the interceptor, after an auth error.
abstract interface class RequestRetrier {
  /// Sends [request], which already carries the auth data to retry with.
  ///
  /// Throws a [DioException] if the request fails.
  ///
  /// Note:
  /// Send it through a [Dio] that doesn't have the interceptor: a request
  /// sent through the interceptor's own [Dio] waits behind the interceptor's
  /// queue, which is waiting for the retry.
  Future<Response<dynamic>> retryRequest(RequestOptions request);
}
