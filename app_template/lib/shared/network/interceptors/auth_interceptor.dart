import 'dart:io';

import 'package:app_template/core/infrastructure/network/interceptors/dio_base_auth_interceptor.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Interceptor to handle authentication request/response/error.
class AuthInterceptor extends DioBaseAuthInterceptor<AuthData> {
  /// {@template field_target_client}
  /// The client where this interceptor is being attached to.
  /// This is required to perform retry requests.
  /// {@endtemplate}
  final Dio _targetClient;

  /// {@template field_auth_data_service}
  /// From where we can read, update and refresh the auth data.
  /// {@endtemplate}
  final AuthDataService _authDataService;

  /// Create an instance of [AuthInterceptor].
  /// - [_targetClient]:
  ///   {@macro field_target_client}
  /// - [_authDataService]
  ///   {@macro field_auth_data_service}
  AuthInterceptor(this._targetClient, this._authDataService);

  @override
  Future<AuthData?> getAuthData() {
    return _authDataService.getCurrentAuthData();
  }

  @override
  bool didServerReportAccessTokenExpiration(DioException error) {
    final errorResponse = error.response;
    if (errorResponse == null) {
      return false;
    }

    if (errorResponse.statusCode != HttpStatus.unauthorized) {
      return false;
    }

    final data = errorResponse.data;
    if (data is! Map<String, dynamic>) {
      return false;
    }

    if (data['error_id'] != 'access_token_expired') {
      return false;
    }

    return true;
  }

  @override
  bool shouldRefreshAuthData(
    RequestOptions requestOptions,
    AuthData currentAuthData,
  ) {
    final requestToken = _getRequestToken(requestOptions);
    return requestToken == null || requestToken == currentAuthData.accessToken;
  }

  @override
  Future<AuthData?> requestAuthDataRefresh(AuthData oldAuthData) async {
    final response = await _authDataService.refreshCurrentAuthData();
    return response.fold(onSuccess: (r) => r, onFailure: (e) => null);
  }

  @override
  Future<Response<dynamic>> retryRequest(
    RequestOptions options,
    AuthData refreshedAuthData,
  ) {
    return _targetClient.fetch(options);
  }

  @override
  Map<String, String> buildAuthorizationHeaders(AuthData authData) {
    return {HttpHeaders.authorizationHeader: 'Bearer ${authData.accessToken}'};
  }

  /// Iterate through Authorization header splits and return the first
  /// valid token.
  ///
  /// There should always be one token in an 'Authorization' header value,
  /// but there can be prefixes before the actual token (eg. 'Bearer'),
  /// hence, we return the first valid token we find. Will return null
  /// if no valid tokens were found.
  String? _getRequestToken(RequestOptions requestOptions) {
    final requestToken =
        requestOptions.headers[HttpHeaders.authorizationHeader];

    if (requestToken == null) {
      return null;
    }

    if (requestToken is! String) {
      return null;
    }

    final splits = requestToken
        .trim()
        .split(RegExp(r'\s+'))
        .map((e) => e.trim());
    for (final split in splits) {
      final decodedToken = JwtDecoder.tryDecode(split);
      if (decodedToken != null) {
        return split;
      }
    }

    return null;
  }
}
