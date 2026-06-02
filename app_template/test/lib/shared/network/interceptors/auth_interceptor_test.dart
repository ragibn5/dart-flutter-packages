// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/shared/network/interceptors/auth_interceptor.dart';
import 'package:core_models/core_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/net_kit.dart';

class _MockNetClient extends Mock implements NetClient {}

class _MockAuthDataService extends Mock implements AuthDataService {}

void main() {
  const userId = 'userId';
  const accessToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.2DPnF-zMjAka6iaq_JE-Tq1ir4d-OALNh-k96HRVLiY';
  const newAccessToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTYxNjIzOTAyMn0.BtpKXeC14PNaSjwp-ZvgcNZYoM9cd5UZp9C_86q-MCk';
  final accessTokenExpiry = DateTime.now().add(const Duration(days: 1));
  final refreshTokenExpiry = accessTokenExpiry.add(const Duration(days: 1));
  final authData = AuthData(
    userId: userId,
    accessToken: accessToken,
    refreshToken: accessToken,
    accessTokenExpiry: accessTokenExpiry,
    refreshTokenExpiry: refreshTokenExpiry,
  );
  final newAuthData = AuthData(
    userId: userId,
    accessToken: newAccessToken,
    refreshToken: accessToken,
    accessTokenExpiry: accessTokenExpiry,
    refreshTokenExpiry: refreshTokenExpiry,
  );
  final tokenRefreshRequest = TokenRefreshRequest(
    refreshToken: authData.refreshToken,
  );

  late RequestSpec authedRequest;
  late RequestSpec emptyRequest;
  late _MockNetClient mockClient;
  late _MockAuthDataService mockAuthDataService;

  late AuthInterceptor sut;

  setUpAll(() {
    registerFallbackValue(tokenRefreshRequest);
    registerFallbackValue(RequestSpec(pathOrUrl: '', method: HttpMethod.GET));
  });

  setUp(() {
    mockClient = _MockNetClient();
    mockAuthDataService = _MockAuthDataService();

    emptyRequest = RequestSpec(
      pathOrUrl: '/test',
      method: HttpMethod.GET,
      headers: {},
    );
    authedRequest = RequestSpec(
      pathOrUrl: '/test',
      method: HttpMethod.GET,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
    );

    sut = AuthInterceptor(mockClient, mockAuthDataService);

    when(
      () => mockAuthDataService.getCurrentAuthData(),
    ).thenAnswer((_) async => authData);
    when(
      () => mockAuthDataService.refreshCurrentAuthData(),
    ).thenAnswer((_) async => Right(Right(authData)));
    when(() => mockClient.execute(spec: any(named: 'spec'))).thenAnswer(
      (_) async => Result.success(
        NetKitResponse(
          isError: false,
          statusCode: HttpStatus.ok,
          data: null,
          headers: {},
          requestSpec: authedRequest,
        ),
      ),
    );
  });

  group('onRequest', () {
    test('injects authorization headers when authenticated', () async {
      final result = await sut.onRequest(emptyRequest);

      expect(result, isA<ContinueWithRequest>());
      expect(
        emptyRequest.headers[HttpHeaders.authorizationHeader],
        'Bearer $accessToken',
      );
    });

    test('rejects request when auth data is unavailable', () async {
      when(
        () => mockAuthDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => null);

      final result = await sut.onRequest(emptyRequest);

      expect(result, isA<ShortRequestWithError>());
      expect(
        (result as ShortRequestWithError).error,
        isA<CancellationException>(),
      );
    });
  });

  group('onResponse', () {
    test(
      'passes through when server did not report token expiration',
      () async {
        final response = RawResponse(
          statusCode: HttpStatus.badRequest,
          rawResponseBody: null,
          responseHeaders: {},
          request: authedRequest,
        );

        final result = await sut.onResponse(response);

        expect(result, isA<ContinueWithResponse>());
      },
    );

    test('rejects when auth data is unavailable on 401', () async {
      when(
        () => mockAuthDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => null);

      final response = RawResponse(
        statusCode: HttpStatus.unauthorized,
        rawResponseBody: {'error_id': 'access_token_expired'},
        responseHeaders: {},
        request: authedRequest,
      );

      final result = await sut.onResponse(response);

      expect(result, isA<ShortResponseWithError>());
      expect(
        (result as ShortResponseWithError).error,
        isA<CancellationException>(),
      );
    });

    test('retries request when auth data was already refreshed', () async {
      when(
        () => mockAuthDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => newAuthData);

      final response = RawResponse(
        statusCode: HttpStatus.unauthorized,
        rawResponseBody: {'error_id': 'access_token_expired'},
        responseHeaders: {},
        request: authedRequest,
      );

      final result = await sut.onResponse(response);

      expect(result, isA<ShortResponseWithFinalResponse>());
      verify(() => mockClient.execute(spec: any(named: 'spec'))).called(1);
    });

    test('refreshes and retries on success', () async {
      when(
        () => mockAuthDataService.refreshCurrentAuthData(),
      ).thenAnswer((_) async => Right(Right(newAuthData)));

      final response = RawResponse(
        statusCode: HttpStatus.unauthorized,
        rawResponseBody: {'error_id': 'access_token_expired'},
        responseHeaders: {},
        request: authedRequest,
      );

      final result = await sut.onResponse(response);

      expect(result, isA<ShortResponseWithFinalResponse>());
      verify(() => mockClient.execute(spec: any(named: 'spec'))).called(1);
    });

    test('rejects when refresh fails', () async {
      when(
        () => mockAuthDataService.refreshCurrentAuthData(),
      ).thenAnswer((_) async => Left(const CancellationError(source: 'test')));

      final response = RawResponse(
        statusCode: HttpStatus.unauthorized,
        rawResponseBody: {'error_id': 'access_token_expired'},
        responseHeaders: {},
        request: authedRequest,
      );

      final result = await sut.onResponse(response);

      expect(result, isA<ShortResponseWithError>());
      expect(
        (result as ShortResponseWithError).error,
        isA<CancellationException>(),
      );
    });
  });
}
