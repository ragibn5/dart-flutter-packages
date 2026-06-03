import 'package:base_auth_interceptor/src/base_auth_data.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/net_kit.dart';

abstract class BaseAuthInterceptor<T extends BaseAuthData>
    extends QueuedNetKitInterceptor {
  /// Returns the current auth data, or `null` if none is available.
  @visibleForOverriding
  Future<T?> getAuthData();

  /// Transforms the outgoing [request] with the given [authData].
  ///
  /// Use this to attach any kind of auth data into the request,
  /// such as adding bearer tokens, or any other auth specific
  /// transformation.
  ///
  /// Params:
  /// - [request]: The input request.
  /// - [authData]: The currently available auth data
  ///   obtained with [getAuthData].
  ///
  /// Returns: A new transformed [RequestSpec] instance,
  /// possibly adapted with the given auth data, which is
  /// sent to the network (or to next interceptor).
  @visibleForOverriding
  Future<RequestSpec> transformRequestWithAuthData(
    RequestSpec request,
    T authData,
  );

  /// Returns `true` when the server response indicates that an
  /// auth error occurred and it should be refreshed.
  @visibleForOverriding
  bool didServerReportAuthError(RawResponse response);

  /// Returns `true` when given [authData] is stale and a refresh
  /// should be attempted.
  ///
  /// This is used for situations like when another request in the
  /// queue already refreshed the auth data, and we no longer need
  /// to perform the auth data refresh.
  @visibleForOverriding
  bool shouldRefreshAuthData(RequestSpec request, T authData);

  /// Attempts to refresh the auth data.
  ///
  /// Returns the new auth data on success, or `null` on failure.
  ///
  /// Note:
  /// When `null` is returned the request is cancelled immediately.
  @visibleForOverriding
  Future<T?> requestAuthDataRefresh(T oldAuthData);

  /// Re-executes [request] with the (possibly refreshed) auth data.
  ///
  /// The returned [ApiCallResult] is remapped into a [RawResponse] by
  /// the template so downstream interceptors see a normal response.
  /// Throw/cancel semantics should be avoided — use the result type.
  @visibleForOverriding
  Future<ApiCallResult> retryRequest(RequestSpec request, T refreshedAuthData);

  @override
  Future<RequestInterceptorResult> onRequest(RequestSpec request) async {
    final authData = await getAuthData();
    if (authData == null) {
      return ShortRequestWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onRequest',
          message:
              'Cancelling `${request.method}` request to `${request.uri}`: '
              'Failed to authorize request, auth data unavailable.',
          request: request,
        ),
      );
    }

    final authorizedRequest =
        await transformRequestWithAuthData(request, authData);
    return ContinueWithRequest(authorizedRequest);
  }

  @override
  Future<ResponseInterceptorResult> onResponse(RawResponse response) async {
    if (!didServerReportAuthError(response)) {
      return ContinueWithResponse(response);
    }

    final request = response.request;
    final method = request.method;
    final uri = request.uri;

    final currentAuthData = await getAuthData();
    if (currentAuthData == null) {
      return ShortResponseWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onResponse',
          message: 'Cancelling `$method` request to `$uri`: '
              'Failed to request auth data refresh (auth data unavailable).',
          request: request,
        ),
      );
    }

    if (!shouldRefreshAuthData(request, currentAuthData)) {
      final response = await retryRequest(request, currentAuthData);
      return response.fold(
        onError: (e) => ShortResponseWithError(
          CancellationException(
            source: '$BaseAuthInterceptor:$onResponse',
            message: 'Cancelling `$method` request to `$uri`: '
                'Request retry failed with possibly refreshed auth data.',
            request: request,
          ),
        ),
        onSuccess: (d) => ShortResponseWithFinalResponse(
          RawResponse(
            statusCode: d.statusCode,
            rawResponseBody: d.data,
            responseHeaders: d.headers,
            request: d.requestSpec,
          ),
        ),
      );
    }

    final refreshedAuthData = await requestAuthDataRefresh(currentAuthData);
    if (refreshedAuthData == null) {
      return ShortResponseWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onResponse',
          message: 'Cancelling `$method` request to `$uri`: '
              'Could not refresh auth data.',
          request: request,
        ),
      );
    }

    final retryResponse = await retryRequest(request, refreshedAuthData);
    return retryResponse.fold(
      onError: (e) => ShortResponseWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onResponse',
          message: 'Cancelling `$method` request to `$uri`: '
              'Failed to retry with refreshed auth data.',
          request: request,
        ),
      ),
      onSuccess: (d) => ShortResponseWithFinalResponse(
        RawResponse(
          statusCode: d.statusCode,
          rawResponseBody: d.data,
          responseHeaders: d.headers,
          request: d.requestSpec,
        ),
      ),
    );
  }
}
