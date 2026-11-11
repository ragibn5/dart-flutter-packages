import 'package:dio/dio.dart';

/// Applies auth data to an outgoing request.
abstract interface class AuthRequestTransformer<AuthData> {
  /// Transforms the outgoing [request] with the given [authData].
  ///
  /// Use this to attach any kind of auth data into the request,
  /// such as adding bearer tokens, or any other auth specific
  /// transformation.
  ///
  /// Params:
  /// - [request]: The input request.
  /// - [authData]: The currently available auth data.
  ///
  /// Returns: The request, possibly adapted with the given auth data, which
  /// is sent to the network (or to the next interceptor). It's also used to
  /// retry a request after an auth error.
  Future<RequestOptions> transformRequestWithAuthData(
    RequestOptions request,
    AuthData authData,
  );
}
