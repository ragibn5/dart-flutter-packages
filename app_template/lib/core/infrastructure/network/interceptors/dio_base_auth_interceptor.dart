import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/base_auth_data.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// A base [Dio] interceptor that handles authenticated requests and
/// automatic token refresh.
///
/// This interceptor:
/// - Injects authorization headers before a request is sent
/// - Detects access-token expiration errors from the server
/// - Refreshes auth data when needed
/// - Retries failed requests transparently
/// - Clears auth data and triggers logout when refresh fails
abstract class DioBaseAuthInterceptor<AuthDataTye extends BaseAuthData>
    extends QueuedInterceptor {
  /// Get the current auth data.
  @visibleForOverriding
  Future<AuthDataTye?> getAuthData();

  //

  /// Determine whether the server reported an access token expiration.
  @visibleForOverriding
  bool didServerReportAccessTokenExpiration(DioException error);

  /// Determine whether we need to refresh the auth data for this request.
  ///
  /// **Note:**
  /// The auth data can be refreshed by a previous call to [onError] method.
  /// If that is the case, we can re-run the request with the new auth data.
  @visibleForOverriding
  bool shouldRefreshAuthData(
    RequestOptions requestOptions,
    AuthDataTye currentAuthData,
  );

  /// A callback through where the interceptor requests auth data refresh.
  ///
  /// Returns the new refreshed [AuthDataTye] on successful refresh, or null if
  /// failed.
  @visibleForOverriding
  Future<AuthDataTye?> requestAuthDataRefresh(AuthDataTye oldAuthData);

  //

  /// A callback through where the interceptor retries a request.
  @visibleForOverriding
  Future<Response<dynamic>> retryRequest(
    RequestOptions options,
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
  /// If auth data is unavailable, the request is rejected immediately
  /// with a [DioException] of type [DioExceptionType.cancel], having
  /// the original [RequestOptions] that initiated the request and the
  /// reason/error of type [CancelledDueToAuthDataUnavailability].
  @mustCallSuper
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authData = await getAuthData();
    if (authData == null) {
      final uri = options.uri.toString();
      final method = options.method.toUpperCase();
      handler.reject(
        DioException.requestCancelled(
          requestOptions: options,
          reason: CancelledDueToAuthDataUnavailability(
            exception: StateError('Auth data unavailable'),
            stackTrace: StackTrace.current,
            message:
                'Cancelling `$method` request to `$uri`: '
                'Failed to add auth header(s), auth data unavailable.',
          ),
        ),
      );

      return;
    }

    buildAuthorizationHeaders(authData).forEach((k, v) {
      options.headers[k] = v;
    });

    handler.next(options);
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
  @mustCallSuper
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If the server did not report access token expiration,
    // propagate the error to next interceptor and return from here.
    if (!didServerReportAccessTokenExpiration(err)) {
      handler.next(err);
      return;
    }

    // Check if we have a valid auth data.
    // If not, reject the request with a [DioException] of type
    // [DioExceptionType.cancel] having the original [RequestOptions]
    // that initiated the request and the reason/error of type
    // [CancelledDueToAuthDataUnavailability].
    final currentAuthData = await getAuthData();
    final requestOptions = err.requestOptions;
    final uri = requestOptions.uri.toString();
    final method = requestOptions.method.toUpperCase();
    if (currentAuthData == null) {
      handler.reject(
        DioException.requestCancelled(
          requestOptions: requestOptions,
          reason: CancelledDueToAuthDataUnavailability(
            exception: err.error,
            stackTrace: err.stackTrace,
            message:
                'Cancelling `$method` request to `$uri`: '
                'Failed to request auth data refresh, auth data unavailable.',
          ),
        ),
      );

      return;
    }

    // Check the current auth data to see if it needs to be refreshed.
    // It may already have been refreshed, and in that case, we can resolve
    // the request with a retry.
    if (!shouldRefreshAuthData(err.requestOptions, currentAuthData)) {
      handler.resolve(await retryRequest(err.requestOptions, currentAuthData));
      return;
    }

    // Attempt to refresh the auth data.
    // If failed, reject the request with a [DioException] of type
    // [DioExceptionType.cancel] having the original [RequestOptions]
    // that initiated the request and the reason/error of type
    // [CancelledDueToAuthDataRefreshFailure].
    final refreshedAuthData = await requestAuthDataRefresh(currentAuthData);
    if (refreshedAuthData == null) {
      handler.reject(
        DioException.requestCancelled(
          requestOptions: requestOptions,
          reason: CancelledDueToAuthDataRefreshFailure(
            exception: err.error,
            stackTrace: err.stackTrace,
            message:
                'Cancelling `$method` request to `$uri`: '
                'Could not refresh auth data.',
          ),
        ),
      );
      return;
    }

    handler.resolve(await retryRequest(err.requestOptions, refreshedAuthData));
  }
}
