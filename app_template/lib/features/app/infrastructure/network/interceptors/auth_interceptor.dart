import 'dart:io';

import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:net_kit/net_kit.dart';

/// Interceptor to handle authentication request/response/error.
class AuthInterceptor extends BaseAuthInterceptor<AuthData> {
  /// {@template field_target_client}
  /// The client where this interceptor is being attached to.
  /// This is required to perform retry requests.
  /// {@endtemplate}
  final NetClient _targetClient;

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
  Future<RequestSpec> transformRequestWithAuthData(
    RequestSpec request,
    AuthData authData,
  ) async {
    return request.copyWith(
      headers: {
        ...request.headers,
        ...{HttpHeaders.authorizationHeader: 'Bearer ${authData.accessToken}'},
      },
    );
  }

  @override
  bool didServerReportAuthError(RawResponse responses) {
    if (responses.statusCode != HttpStatus.unauthorized) {
      return false;
    }

    final data = responses.rawResponseBody;
    if (data is! Map<String, dynamic>) {
      return false;
    }

    if (data['error_id'] != 'access_token_expired') {
      return false;
    }

    return true;
  }

  @override
  bool shouldRefreshAuthData(RequestSpec request, AuthData authData) {
    final requestToken = _getRequestToken(request);
    return requestToken == null || requestToken == authData.accessToken;
  }

  @override
  Future<AuthData?> requestAuthDataRefresh(AuthData oldAuthData) async {
    final response = await _authDataService.refreshCurrentAuthData();
    return response.fold(
      onLeft: (e) => null,
      onRight: (r) => r.fold(onLeft: (l) => null, onRight: (r) => r),
    );
  }

  @override
  Future<ApiCallResult> retryRequest(
    RequestSpec request,
    AuthData refreshedAuthData,
  ) {
    return _targetClient.execute(spec: request);
  }

  /// Iterate through Authorization header splits and return the first
  /// valid token.
  ///
  /// There should always be one token in an 'Authorization' header value,
  /// but there can be prefixes before the actual token (eg. 'Bearer'),
  /// hence, we return the first valid token we find. Will return null
  /// if no valid tokens were found.
  String? _getRequestToken(RequestSpec request) {
    final requestToken = request.headers[HttpHeaders.authorizationHeader];

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
