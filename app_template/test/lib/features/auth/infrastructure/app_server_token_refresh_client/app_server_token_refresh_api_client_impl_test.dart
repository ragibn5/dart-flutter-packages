// ignore_for_file: lines_longer_than_80_char
// ignore_for_file: avoid_redundant_argument_values

import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/server_message.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client_impl.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockDioFeatureApiErrorMapper extends Mock
    implements AppServerTokenRefreshApiErrorMapper {}

void main() {
  const path = AppServerTokenRefreshApiClientImpl.path;
  const tokenRefreshRequest = TokenRefreshRequest(refreshToken: 'refreshToken');

  final now = DateTime.now().toUtc();
  final options = Options(method: 'GET');
  final sampleAuthData = AuthDataDTO(
    userId: 'userId',
    accessToken: 'new_access_token',
    refreshToken: 'new_refresh_token',
    accessTokenExpiry: now.add(const Duration(days: 1)),
    refreshTokenExpiry: now.add(const Duration(days: 2)),
  );

  late _MockDio mockDio;
  late _MockDioFeatureApiErrorMapper mockErrorMapper;

  late AppServerTokenRefreshApiClientImpl sut;

  setUpAll(() {
    registerFallbackValue(options);
    registerFallbackValue(tokenRefreshRequest);
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    mockDio = _MockDio();
    mockErrorMapper = _MockDioFeatureApiErrorMapper();

    sut = AppServerTokenRefreshApiClientImpl(mockDio, mockErrorMapper);
  });

  test('createRequest returns request model with proper values', () {
    final result = sut.createRequest(tokenRefreshRequest);

    expect(result.pathOrUrl, path);
    expect(result.data, tokenRefreshRequest.toJson());
    expect(result.options?.method?.toUpperCase(), 'GET');
  });

  test('decodeResponse returns AuthDataDTO from response data', () {
    final result = sut.decodeResponse(sampleAuthData.toJson());

    expect(result, isA<AuthDataDTO>());
    expect(result, sampleAuthData);
  });

  test('request returns success when API call succeeds', () async {
    when(
      () => mockDio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
        onSendProgress: any(named: 'onSendProgress'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
      ),
    ).thenAnswer(
      (_) async => Response(
        data: sampleAuthData.toJson(),
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
      ),
    );

    final result = await sut.request(tokenRefreshRequest);

    expect(result.isSuccess, true);
    result.fold(
      onSuccess: (data) {
        expect(data, isA<AuthDataDTO>());
        expect(data, sampleAuthData);
      },
      onFailure: (_) => fail('Expected success'),
    );

    verify(
      () => mockDio.request<dynamic>(
        path,
        data: tokenRefreshRequest.toJson(),
        queryParameters: null,
        cancelToken: null,
        onSendProgress: null,
        onReceiveProgress: null,
      ),
    ).called(1);
  });

  test('request returns failure when API call throws exception', () async {
    final exception = DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.connectionTimeout,
    );
    final mappedError = ApiError<ServerError<ServerMessage>>.fromNetworkError(
      const ConnectionTimeout(message: 'Connection timeout'),
    );

    when(
      () => mockDio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
        onSendProgress: any(named: 'onSendProgress'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
      ),
    ).thenThrow(exception);

    when(() => mockErrorMapper.mapError(any(), any())).thenReturn(mappedError);

    final result = await sut.request(tokenRefreshRequest);

    expect(result.isError, true);
    result.fold(
      onSuccess: (_) => fail('Expected failure'),
      onFailure: (error) {
        expect(error, mappedError);
        expect(error.isNetworkError, true);
      },
    );

    verify(() => mockErrorMapper.mapError(exception, any())).called(1);
  });
}
