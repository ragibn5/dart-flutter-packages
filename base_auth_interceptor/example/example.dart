import 'dart:io';

import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:dio/dio.dart';

class _AuthDataProvider implements AuthDataProvider<String> {
  @override
  Future<String?> getAuthData() async => 'my-token';

  @override
  Future<String?> requestAuthDataRefresh(String oldAuthData) async =>
      'my-new-token';
}

class _AuthRefreshPolicy implements AuthRefreshPolicy<String> {
  @override
  bool didServerReportAuthError(Response<dynamic> response) =>
      response.statusCode == HttpStatus.unauthorized;

  /// Refresh only if the request was sent with the current auth data;
  /// otherwise another request has refreshed it already.
  @override
  bool shouldRefreshAuthData(RequestOptions request, String authData) =>
      request.headers[HttpHeaders.authorizationHeader] == 'Bearer $authData';
}

class _AuthRequestTransformer implements AuthRequestTransformer<String> {
  @override
  Future<RequestOptions> transformRequestWithAuthData(
    RequestOptions request,
    String authData,
  ) async =>
      request.copyWith(
        headers: {
          ...request.headers,
          HttpHeaders.authorizationHeader: 'Bearer $authData',
        },
      );
}

/// Retries through a [Dio] without the auth interceptor.
class _RequestRetrier implements RequestRetrier {
  final Dio _dio;

  _RequestRetrier(this._dio);

  @override
  Future<Response<dynamic>> retryRequest(RequestOptions request) =>
      _dio.fetch<dynamic>(request);
}

class AppAuthInterceptor extends BaseAuthInterceptor<String> {
  AppAuthInterceptor(Dio retryDio)
      : super(
          _AuthDataProvider(),
          _AuthRefreshPolicy(),
          _AuthRequestTransformer(),
          _RequestRetrier(retryDio),
        );
}

void main() {
  final options = BaseOptions(baseUrl: 'https://example.com');
  Dio(options)
    ..interceptors.add(AppAuthInterceptor(Dio(options)))
    ..get<dynamic>('/profile');
}
