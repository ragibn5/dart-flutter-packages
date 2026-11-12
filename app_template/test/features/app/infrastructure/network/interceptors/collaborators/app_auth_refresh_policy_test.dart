// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/collaborators/app_auth_refresh_policy.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const expiredToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.2DPnF-zMjAka6iaq_JE-Tq1ir4d-OALNh-k96HRVLiY';
  const newerToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTYxNjIzOTAyMn0.BtpKXeC14PNaSjwp-ZvgcNZYoM9cd5UZp9C_86q-MCk';

  const policy = AppAuthRefreshPolicy();

  RequestOptions requestWithToken(String? token) => RequestOptions(
    headers: {
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    },
  );

  Response<dynamic> response(int statusCode, Object? body) => Response(
    requestOptions: RequestOptions(),
    statusCode: statusCode,
    data: body,
  );

  test('didServerReportAuthErrorShouldReturnTrueIfTheTokenExpired', () {
    expect(
      policy.didServerReportAuthError(
        response(HttpStatus.unauthorized, {'error_id': 'access_token_expired'}),
      ),
      isTrue,
    );
  });

  test('didServerReportAuthErrorShouldReturnFalseIfNotUnauthorized', () {
    expect(
      policy.didServerReportAuthError(
        response(HttpStatus.badRequest, {'error_id': 'access_token_expired'}),
      ),
      isFalse,
    );
  });

  test('didServerReportAuthErrorShouldReturnFalseIfAnotherError', () {
    expect(
      policy.didServerReportAuthError(
        response(HttpStatus.unauthorized, {'error_id': 'other_error'}),
      ),
      isFalse,
    );
  });

  test('didServerReportAuthErrorShouldReturnFalseIfTheBodyIsNotAMap', () {
    expect(
      policy.didServerReportAuthError(
        response(HttpStatus.unauthorized, 'not-a-map'),
      ),
      isFalse,
    );
  });

  AuthInfo authInfo(String token) => AuthInfo(
    accessToken: token,
    refreshToken: 'refresh',
    accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
    refreshTokenExpiry: DateTime.now().add(const Duration(days: 2)),
  );

  test('shouldRefreshAuthDataShouldReturnTrueIfTheRequestHasTheSameToken', () {
    expect(
      policy.shouldRefreshAuthData(
        requestWithToken(expiredToken),
        authInfo(expiredToken),
      ),
      isTrue,
    );
  });

  test('shouldRefreshAuthDataShouldReturnFalseIfTheRequestHasANewerToken', () {
    expect(
      policy.shouldRefreshAuthData(
        requestWithToken(newerToken),
        authInfo(expiredToken),
      ),
      isFalse,
    );
  });

  test('shouldRefreshAuthDataShouldReturnTrueIfThereIsNoAuthHeader', () {
    expect(
      policy.shouldRefreshAuthData(
        requestWithToken(null),
        authInfo(expiredToken),
      ),
      isTrue,
    );
  });

  test('shouldRefreshAuthDataShouldReturnTrueIfTheAuthHeaderIsInvalid', () {
    final request = RequestOptions(
      headers: {HttpHeaders.authorizationHeader: 'not-a-jwt'},
    );

    expect(
      policy.shouldRefreshAuthData(request, authInfo(expiredToken)),
      isTrue,
    );
  });
}
