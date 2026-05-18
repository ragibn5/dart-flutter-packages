import 'package:app_template/core/models/base_auth_data.dart';
import 'package:meta/meta.dart';
import 'package:net_kit/net_kit.dart';

/// A base interceptor that handles authenticated requests and
/// automatic token refresh.
///
/// This interceptor:
/// - Injects authorization headers before a request is sent
/// - Detects access-token expiration errors from the server
/// - Refreshes auth data when needed
/// - Retries failed requests transparently
/// - Clears auth data and triggers logout when refresh fails
abstract class BaseAuthInterceptor<AuthDataTye extends BaseAuthData>
    extends QueuedNetKitInterceptor {
  /// Get the current auth data.
  @visibleForOverriding
  Future<AuthDataTye?> getAuthData();

  //

  /// Determine whether the server reported an access token expiration.
  @visibleForOverriding
  bool didServerReportAccessTokenExpiration(RawResponse response);

  /// Determine whether we need to refresh the auth data for this request.
  ///
  /// **Note:**
  /// The auth data can be refreshed by a previous call to [onError] method.
  /// If that is the case, we can re-run the request with the new auth data.
  @visibleForOverriding
  bool shouldRefreshAuthData(RequestSpec request, AuthDataTye currentAuthData);

  /// A callback through where the interceptor requests auth data refresh.
  ///
  /// Returns the new refreshed [AuthDataTye] on successful refresh, or null if
  /// failed.
  @visibleForOverriding
  Future<AuthDataTye?> requestAuthDataRefresh(AuthDataTye oldAuthData);

  //

  /// A callback through where the interceptor retries a request.
  @visibleForOverriding
  Future<ApiCallResult> retryRequest(
    RequestSpec request,
    AuthDataTye refreshedAuthData,
  );

  /// Builds authorization-related headers from the given auth data.
  ///
  /// This is where access tokens (and related metadata) should be attached,
  /// e.g.:
  /// ```dart
  /// {
  ///   'Authorization': 'Bearer <token>',
  /// }
  /// ```
  @visibleForOverriding
  Map<String, String> buildAuthorizationHeaders(AuthDataTye authData);

  /// Intercepts outgoing requests and injects authorization headers
  /// defined by [buildAuthorizationHeaders].
  ///
  /// If auth data is unavailable, the request is rejected with a
  /// [CancellationException].
  @override
  Future<RequestInterceptorResult> onRequest(RequestSpec request) async {
    final authData = await getAuthData();
    if (authData == null) {
      return ShortRequestWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onRequest',
          message:
              'Cancelling `${request.method}` request to `${request.uri}`: '
              'Failed to add auth header(s), auth data unavailable.',
          request: request,
        ),
      );
    }

    buildAuthorizationHeaders(authData).forEach((k, v) {
      request.headers?[k] = v;
    });

    return ContinueWithRequest(request);
  }

  /// Handles authentication-related request failures.
  ///
  /// Flow:
  /// 1. Ignore errors unrelated to token expiration
  /// 2. Abort and logout if auth data is missing
  /// 3. Retry immediately if auth data was already refreshed
  /// 4. Attempt token refresh
  /// 5. Retry request on success
  /// 6. Logout on refresh failure
  @override
  Future<ResponseInterceptorResult> onResponse(RawResponse response) async {
    // If the server did not report access token expiration,
    // propagate the error to next interceptor and return from here.
    if (!didServerReportAccessTokenExpiration(response)) {
      return ContinueWithResponse(response);
    }

    final request = response.request;
    final method = request.method;
    final uri = request.uri;

    // Check if we have a valid auth data.
    // If not, reject the request with a [CancellationException].
    final currentAuthData = await getAuthData();
    if (currentAuthData == null) {
      return ShortResponseWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onResponse',
          message:
              'Cancelling `$method` request to `$uri`: '
              'Failed to request auth data refresh (auth data unavailable).',
          request: request,
        ),
      );
    }

    // Check the current auth data to see if it needs to be refreshed.
    // It may already have been refreshed, and in that case, we can resolve
    // the request with a retry.
    if (!shouldRefreshAuthData(request, currentAuthData)) {
      final response = await retryRequest(request, currentAuthData);
      return response.fold(
        onError: (e) => ShortResponseWithError(
          CancellationException(
            source: '$BaseAuthInterceptor:$onResponse',
            message:
                'Cancelling `$method` request to `$uri`: '
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

    // Attempt to refresh the auth data.
    // If failed, reject the request with a [CancellationException].
    final refreshedAuthData = await requestAuthDataRefresh(currentAuthData);
    if (refreshedAuthData == null) {
      return ShortResponseWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onResponse',
          message:
              'Cancelling `$method` request to `$uri`: '
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
          message:
              'Cancelling `$method` request to `$uri`: '
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
