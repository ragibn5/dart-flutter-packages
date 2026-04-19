// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/result.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/shared/network/interceptors/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockAuthDataService extends Mock implements AuthDataService {}

class _MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class _MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class _FakeRequestOptions extends Fake implements RequestOptions {}

class _FakeDioException extends Fake implements DioException {}

class _FakeResponse extends Fake implements Response<dynamic> {}

void main() {
  const userId = 'userId';
  const accessToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.2DPnF-zMjAka6iaq_JE-Tq1ir4d-OALNh-k96HRVLiY';
  const newAccessToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTYxNjIzOTAyMn0.BtpKXeC14PNaSjwp-ZvgcNZYoM9cd5UZp9C_86q-MCk';
  const refreshToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MjAxNjIzOTAyMn0.BcjQmLA8URPyxBh8LR0wt45-bWd9Fy1bfpWyn2ctix8';
  final accessTokenExpiry = DateTime.now().add(const Duration(days: 1));
  final refreshTokenExpiry = accessTokenExpiry.add(const Duration(days: 1));
  final authData = AuthData(
    userId: userId,
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessTokenExpiry: accessTokenExpiry,
    refreshTokenExpiry: refreshTokenExpiry,
  );
  final newAuthData = AuthData(
    userId: userId,
    accessToken: newAccessToken,
    refreshToken: refreshToken,
    accessTokenExpiry: accessTokenExpiry,
    refreshTokenExpiry: refreshTokenExpiry,
  );
  final tokenRefreshRequest = TokenRefreshRequest(
    refreshToken: authData.refreshToken,
  );

  late Map<String, String> emptyHeaders;
  late RequestOptions emptyRequestOptions;
  late Map<String, String> authedHeaders;
  late RequestOptions authedRequestOptions;

  late _MockDio mockClient;
  late _MockAuthDataService mockAuthDataService;
  late _MockRequestInterceptorHandler mockRequestHandler;
  late _MockErrorInterceptorHandler mockErrorHandler;

  late AuthInterceptor sut;

  setUpAll(() {
    registerFallbackValue(tokenRefreshRequest);
    registerFallbackValue(_FakeRequestOptions());
    registerFallbackValue(_FakeDioException());
    registerFallbackValue(_FakeResponse());
  });

  setUp(() {
    mockClient = _MockDio();
    mockAuthDataService = _MockAuthDataService();
    mockRequestHandler = _MockRequestInterceptorHandler();
    mockErrorHandler = _MockErrorInterceptorHandler();

    emptyHeaders = {};
    emptyRequestOptions = RequestOptions(path: '/test', headers: emptyHeaders);
    authedHeaders = {HttpHeaders.authorizationHeader: 'Bearer $accessToken'};
    authedRequestOptions = RequestOptions(
      path: '/test',
      headers: authedHeaders,
    );

    sut = AuthInterceptor(mockClient, mockAuthDataService);

    when(
      () => mockAuthDataService.getCurrentAuthData(),
    ).thenAnswer((_) async => authData);
    when(
      () => mockAuthDataService.refreshCurrentAuthData(),
    ).thenAnswer((_) async => Result.success(authData));
    when(
      () => mockClient.fetch<dynamic>(any()),
    ).thenAnswer((_) async => Response(requestOptions: authedRequestOptions));
  });

  test(
    'If authenticated, `onRequest` should inject authorization headers and proceed with the request',
    () async {
      await sut.onRequest(emptyRequestOptions, mockRequestHandler);

      expect(emptyRequestOptions.headers, isNotEmpty);
      expect(
        emptyRequestOptions.headers,
        containsPair(HttpHeaders.authorizationHeader, 'Bearer $accessToken'),
      );
      verify(() => mockRequestHandler.next(emptyRequestOptions)).called(1);
    },
  );

  test(
    'If not authenticated, `onRequest` should not inject authorization headers and should reject the request with a `DioException` of type `DioExceptionType.cancel`',
    () async {
      when(
        () => mockAuthDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => null);

      await sut.onRequest(emptyRequestOptions, mockRequestHandler);

      expect(emptyRequestOptions.headers, isEmpty);

      final verification = verify(
        () => mockRequestHandler.reject(captureAny()),
      );
      final exception = verification.captured.single as DioException;

      verification.called(1);
      expect(exception.requestOptions, emptyRequestOptions);
      expect(exception.type, DioExceptionType.cancel);
      expect(exception.error, isA<CancelledDueToAuthDataUnavailability>());
    },
  );

  test(
    'Should propagate error to next interceptor if it is not an authorization error',
    () async {
      final exception = DioException(
        requestOptions: authedRequestOptions,
        response: Response(
          requestOptions: authedRequestOptions,
          statusCode: HttpStatus.badRequest,
        ),
      );

      await sut.onError(exception, mockErrorHandler);

      verify(() => mockErrorHandler.next(exception)).called(1);
    },
  );

  test(
    'Should reject the request with a `DioException` of type `DioExceptionType.cancel` if auth data is no longer available by the time we are in `onError`',
    () async {
      final dioException = DioException(
        requestOptions: authedRequestOptions,
        response: Response(
          requestOptions: authedRequestOptions,
          statusCode: HttpStatus.unauthorized,
          data: {'error_id': 'access_token_expired'},
        ),
      );

      when(
        () => mockAuthDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => null);

      await sut.onError(dioException, mockErrorHandler);

      final verification = verify(() => mockErrorHandler.reject(captureAny()));
      final customException = verification.captured.single as DioException;

      verification.called(1);
      expect(customException.requestOptions, authedRequestOptions);
      expect(customException.type, DioExceptionType.cancel);
      expect(
        customException.error,
        isA<CancelledDueToAuthDataUnavailability>(),
      );
    },
  );

  test(
    'Should resolve the request if auth data has already been refreshed by previously queued requests',
    () async {
      final dioException = DioException(
        requestOptions: authedRequestOptions,
        response: Response(
          requestOptions: authedRequestOptions,
          statusCode: HttpStatus.unauthorized,
          data: {'error_id': 'access_token_expired'},
        ),
      );

      when(
        () => mockAuthDataService.getCurrentAuthData(),
      ).thenAnswer((_) async => newAuthData);

      await sut.onError(dioException, mockErrorHandler);

      verify(() => mockErrorHandler.resolve(any())).called(1);
      verify(() => mockClient.fetch<dynamic>(any())).called(1);
    },
  );

  test(
    'If expired, should try to refresh auth data, and on success, resolve the request with a retry.',
    () async {
      final dioException = DioException(
        requestOptions: authedRequestOptions,
        response: Response(
          requestOptions: authedRequestOptions,
          statusCode: HttpStatus.unauthorized,
          data: {'error_id': 'access_token_expired'},
        ),
      );

      await sut.onError(dioException, mockErrorHandler);

      verify(() => mockErrorHandler.resolve(any())).called(1);
      verify(() => mockClient.fetch<dynamic>(any())).called(1);
    },
  );

  test(
    'If expired, should try to refresh auth data, and on failure, should reject the request with a `DioException` of type `DioExceptionType.cancel`',
    () async {
      final dioException = DioException(
        requestOptions: authedRequestOptions,
        response: Response(
          requestOptions: authedRequestOptions,
          statusCode: HttpStatus.unauthorized,
          data: {'error_id': 'access_token_expired'},
        ),
      );

      when(() => mockAuthDataService.refreshCurrentAuthData()).thenAnswer(
        (_) async => Result.failure(
          ApiError.fromServerError(InvalidAuthStateForRefresh()),
        ),
      );

      await sut.onError(dioException, mockErrorHandler);

      final verification = verify(() => mockErrorHandler.reject(captureAny()));
      final customException = verification.captured.single as DioException;

      verification.called(1);
      expect(customException.requestOptions, authedRequestOptions);
      expect(customException.type, DioExceptionType.cancel);
      expect(
        customException.error,
        isA<CancelledDueToAuthDataRefreshFailure>(),
      );
    },
  );
}
