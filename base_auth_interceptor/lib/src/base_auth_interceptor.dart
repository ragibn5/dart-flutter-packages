import 'package:base_auth_interceptor/src/auth_data_provider.dart';
import 'package:base_auth_interceptor/src/auth_recovery_exception.dart';
import 'package:base_auth_interceptor/src/auth_refresh_policy.dart';
import 'package:base_auth_interceptor/src/auth_request_transformer.dart';
import 'package:base_auth_interceptor/src/request_retrier.dart';
import 'package:dio/dio.dart';

/// Authorizes requests, and recovers from auth errors by refreshing the auth
/// data and retrying the request.
///
/// Note:
/// Requests and responses pass through one at a time, so concurrent auth
/// errors lead to a single refresh.
abstract class BaseAuthInterceptor<AuthData> extends QueuedInterceptor {
  final AuthDataProvider<AuthData> _authDataProvider;
  final AuthRefreshPolicy<AuthData> _refreshPolicy;
  final AuthRequestTransformer<AuthData> _requestTransformer;
  final RequestRetrier _requestRetrier;

  BaseAuthInterceptor(
    this._authDataProvider,
    this._refreshPolicy,
    this._requestTransformer,
    this._requestRetrier,
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    return _guard(options, handler.reject, () async {
      final authData = await _authDataProvider.getAuthData();
      if (authData == null) {
        throw _cancellation(options, AuthRecoveryFailure.authDataUnavailable);
      }

      handler.next(
        await _requestTransformer.transformRequestWithAuthData(
          options,
          authData,
        ),
      );
    });
  }

  /// Recovers from an auth error that arrives as a response: one whose status
  /// the [Dio]'s `validateStatus` accepts.
  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    return _guard(response.requestOptions, handler.reject, () async {
      if (!_refreshPolicy.didServerReportAuthError(response)) {
        handler.next(response);
        return;
      }

      handler.resolve(await _recover(response.requestOptions));
    });
  }

  /// Recovers from an auth error that arrives as an error: one whose status
  /// the [Dio]'s `validateStatus` rejects, as a 401 is by default.
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) {
    return _guard(err.requestOptions, handler.reject, () async {
      final response = err.response;
      if (response == null ||
          !_refreshPolicy.didServerReportAuthError(response)) {
        handler.next(err);
        return;
      }

      handler.resolve(await _recover(err.requestOptions));
    });
  }

  Future<Response<dynamic>> _recover(RequestOptions request) async {
    final currentAuthData = await _authDataProvider.getAuthData();
    if (currentAuthData == null) {
      throw _cancellation(request, AuthRecoveryFailure.authDataUnavailable);
    }

    // Another request may have refreshed the auth data already.
    var authData = currentAuthData;
    if (_refreshPolicy.shouldRefreshAuthData(request, currentAuthData)) {
      final refreshedAuthData = await _authDataProvider.requestAuthDataRefresh(
        currentAuthData,
      );
      if (refreshedAuthData == null) {
        throw _cancellation(request, AuthRecoveryFailure.refreshFailed);
      }
      authData = refreshedAuthData;
    }

    final retryRequest = await _requestTransformer.transformRequestWithAuthData(
        request, authData);
    try {
      return await _requestRetrier.retryRequest(retryRequest);
    } catch (e) {
      throw _cancellation(request, AuthRecoveryFailure.retryFailed, cause: e);
    }
  }

  /// Runs [body], and rejects the request with what it throws: an
  /// unexpected error would otherwise leave the request hanging.
  Future<void> _guard(
    RequestOptions request,
    void Function(DioException) reject,
    Future<void> Function() body,
  ) async {
    try {
      await body();
    } on DioException catch (e) {
      reject(e);
    } catch (e, stackTrace) {
      reject(
        DioException(requestOptions: request, error: e, stackTrace: stackTrace),
      );
    }
  }

  DioException _cancellation(
    RequestOptions request,
    AuthRecoveryFailure reason, {
    Object? cause,
  }) {
    return DioException(
      requestOptions: request,
      type: DioExceptionType.cancel,
      error: AuthRecoveryException(reason, cause: cause),
      message: 'Cancelled `${request.method}` request to `${request.uri}`: '
          '${reason.name}.',
    );
  }
}
