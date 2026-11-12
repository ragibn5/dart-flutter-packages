import 'dart:io';

import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/collaborators/app_auth_request_transformer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const accessToken = 'access-token';
  final authInfo = AuthInfo(
    accessToken: accessToken,
    refreshToken: 'refresh',
    accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
    refreshTokenExpiry: DateTime.now().add(const Duration(days: 2)),
  );

  const transformer = AppAuthRequestTransformer();

  test('transformRequestWithAuthDataShouldAddTheBearerTokenIfCalled', () async {
    final request = RequestOptions();

    final result = await transformer.transformRequestWithAuthData(
      request,
      authInfo,
    );

    expect(
      result.headers[HttpHeaders.authorizationHeader],
      'Bearer $accessToken',
    );
  });

  test('transformRequestWithAuthDataShouldKeepOtherHeadersIfPresent', () async {
    final request = RequestOptions(
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );

    final result = await transformer.transformRequestWithAuthData(
      request,
      authInfo,
    );

    expect(result.headers[HttpHeaders.contentTypeHeader], 'application/json');
    expect(
      result.headers[HttpHeaders.authorizationHeader],
      'Bearer $accessToken',
    );
  });

  test(
    'transformRequestWithAuthDataShouldReplaceTheAuthHeaderIfPresent',
    () async {
      final request = RequestOptions(
        headers: {HttpHeaders.authorizationHeader: 'Bearer old-token'},
      );

      final result = await transformer.transformRequestWithAuthData(
        request,
        authInfo,
      );

      expect(
        result.headers[HttpHeaders.authorizationHeader],
        'Bearer $accessToken',
      );
    },
  );
}
