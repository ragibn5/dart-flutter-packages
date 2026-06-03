import 'dart:io';

import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/shared/network/interceptors/auth_interceptor.dart';
import 'package:core_models/core_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/net_kit.dart';

class _MockNetClient extends Mock implements NetClient {}

class _MockAuthDataService extends Mock implements AuthDataService {}

void main() {
  const accessToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.2DPnF-zMjAka6iaq_JE-Tq1ir4d-OALNh-k96HRVLiY';
  const newAccessToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTYxNjIzOTAyMn0.BtpKXeC14PNaSjwp-ZvgcNZYoM9cd5UZp9C_86q-MCk';
  final authData = AuthData(
    userId: 'id',
    accessToken: accessToken,
    refreshToken: 'refresh',
    accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
    refreshTokenExpiry: DateTime.now().add(const Duration(days: 2)),
  );
  final newAuthData = AuthData(
    userId: 'id',
    accessToken: newAccessToken,
    refreshToken: 'refresh',
    accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
    refreshTokenExpiry: DateTime.now().add(const Duration(days: 2)),
  );

  late _MockNetClient mockClient;
  late _MockAuthDataService mockAuthDataService;

  late AuthInterceptor sut;

  setUpAll(() {
    registerFallbackValue(RequestSpec(pathOrUrl: '', method: HttpMethod.GET));
  });

  setUp(() {
    mockClient = _MockNetClient();
    mockAuthDataService = _MockAuthDataService();
    sut = AuthInterceptor(mockClient, mockAuthDataService);
  });

  group('transformRequestWithAuthData', () {
    test('Adds bearer token to authorization header', () async {
      final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);

      final result = await sut.transformRequestWithAuthData(request, authData);

      expect(
        result.headers[HttpHeaders.authorizationHeader],
        'Bearer $accessToken',
      );
    });
  });

  group('didServerReportAuthError', () {
    test('Returns true for 401 with access_token_expired', () {
      final response = RawResponse(
        statusCode: HttpStatus.unauthorized,
        rawResponseBody: {'error_id': 'access_token_expired'},
        responseHeaders: {},
        request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
      );

      expect(sut.didServerReportAuthError(response), isTrue);
    });

    test('Returns false for 401 without access_token_expired', () {
      final response = RawResponse(
        statusCode: HttpStatus.unauthorized,
        rawResponseBody: {'error_id': 'other_error'},
        responseHeaders: {},
        request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
      );

      expect(sut.didServerReportAuthError(response), isFalse);
    });

    test('Returns false for non-401 status code', () {
      final response = RawResponse(
        statusCode: HttpStatus.badRequest,
        rawResponseBody: {'error_id': 'access_token_expired'},
        responseHeaders: {},
        request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
      );

      expect(sut.didServerReportAuthError(response), isFalse);
    });
  });

  group('getAuthData', () {
    test('Delegates to auth data service', () async {
      when(
        () => mockAuthDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => authData);

      final result = await sut.getAuthData();

      expect(result, same(authData));
    });
  });

  group('requestAuthDataRefresh', () {
    test('Delegates to auth data service', () async {
      when(
        () => mockAuthDataService.refreshCurrentAuthData(),
      ).thenAnswer((_) async => Right(Right(newAuthData)));

      final result = await sut.requestAuthDataRefresh(authData);

      expect(result, same(newAuthData));
    });

    test('Returns null when service returns Left', () async {
      when(
        () => mockAuthDataService.refreshCurrentAuthData(),
      ).thenAnswer((_) async => Left(CancellationError(source: 'test')));

      final result = await sut.requestAuthDataRefresh(authData);

      expect(result, isNull);
    });

    test('Returns null when inner Left returns null', () async {
      when(
        () => mockAuthDataService.refreshCurrentAuthData(),
      ).thenAnswer((_) async => Right(Left(InvalidRefreshToken())));

      final result = await sut.requestAuthDataRefresh(authData);

      expect(result, isNull);
    });
  });

  group('retryRequest', () {
    test('Executes on target client', () async {
      final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);
      when(() => mockClient.execute(spec: any(named: 'spec'))).thenAnswer(
        (_) async => Result.success(
          NetKitResponse(
            isError: false,
            statusCode: HttpStatus.ok,
            data: null,
            headers: {},
            requestSpec: request,
          ),
        ),
      );

      final result = await sut.retryRequest(request, authData);

      expect(result.isSuccess, isTrue);
      verify(() => mockClient.execute(spec: request)).called(1);
    });
  });

  group('shouldRefreshAuthData', () {
    test('Returns true when request has no auth header', () {
      final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);

      expect(sut.shouldRefreshAuthData(request, authData), isTrue);
    });

    test('Returns true when request has the same expired token', () {
      final request = RequestSpec(
        pathOrUrl: '/test',
        method: HttpMethod.GET,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
      );

      expect(sut.shouldRefreshAuthData(request, authData), isTrue);
    });

    test('Returns false when request already has a newer token', () {
      final request = RequestSpec(
        pathOrUrl: '/test',
        method: HttpMethod.GET,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $newAccessToken'},
      );

      expect(sut.shouldRefreshAuthData(request, authData), isFalse);
    });
  });
}
