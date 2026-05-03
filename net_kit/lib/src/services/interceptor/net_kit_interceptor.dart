import 'package:net_kit/net_kit.dart';

/// An interceptor for the client.
abstract class NetKitInterceptor {
  /// Intercept the request.
  ///
  /// Called before the request is sent.
  Future<RequestInterceptorResult> onRequest(
    RequestSpec request,
  ) async =>
      ContinueWithRequest(request);

  /// Intercept the response.
  ///
  /// Called after the response is received.
  Future<ResponseInterceptorResult> onResponse(
    ResponseContext response,
  ) async =>
      ContinueWithResponse(response);

  /// Intercept the error.
  ///
  /// Called when an error occurs.
  Future<ErrorInterceptorResult> onError(NetKitException error) async =>
      ContinueWithError(error);
}
