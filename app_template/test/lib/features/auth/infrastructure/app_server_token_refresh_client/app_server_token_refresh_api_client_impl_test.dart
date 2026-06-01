// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/api_response.dart';
import 'package:app_template/core/models/server_message.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/net_kit.dart';

class _MockNetClient extends Mock implements NetClient {}

void main() {
  const path = AppServerTokenRefreshApiClientImpl.path;
  const tokenRefreshRequest = TokenRefreshRequest(refreshToken: 'refreshToken');

  final now = DateTime.now().toUtc();
  final sampleAuthData = AuthDataDTO(
    userId: 'userId',
    accessToken: 'new_access_token',
    refreshToken: 'new_refresh_token',
    accessTokenExpiry: now.add(const Duration(days: 1)),
    refreshTokenExpiry: now.add(const Duration(days: 2)),
  );
  const sampleServerMessage = ServerMessage(code: 'error', message: 'Error');

  late _MockNetClient mockNetClient;
  late AppServerTokenRefreshApiClientImpl sut;

  setUpAll(() {
    registerFallbackValue(RequestSpec(pathOrUrl: '', method: HttpMethod.GET));
    registerFallbackValue(const DefaultResponseClassifier());
  });

  setUp(() {
    mockNetClient = _MockNetClient();
    sut = AppServerTokenRefreshApiClientImpl(mockNetClient);
  });

  test('createRequest returns request model with proper values', () {
    final result = sut.createRequest(tokenRefreshRequest);

    expect(result.pathOrUrl, path);
    expect(result.method, HttpMethod.GET);
    expect(result.body, isA<JsonBody>());
    final body = result.body! as JsonBody;
    expect(body.data, tokenRefreshRequest.toJson());
  });

  test('decodeResponse returns AuthDataDTO from non-error response', () {
    final response = NetKitResponse(
      isError: false,
      statusCode: 200,
      data: sampleAuthData.toJson(),
      headers: {},
      requestSpec: RequestSpec(pathOrUrl: '', method: HttpMethod.GET),
    );

    final result = sut.decodeResponse(response);

    expect(result, isA<Success<AuthDataDTO>>());
    expect((result as Success).data, sampleAuthData);
  });

  test('decodeResponse returns Failure from error response', () {
    final response = NetKitResponse(
      isError: true,
      statusCode: 400,
      data: sampleServerMessage.toJson(),
      headers: {},
      requestSpec: RequestSpec(pathOrUrl: '', method: HttpMethod.GET),
    );

    final result = sut.decodeResponse(response);

    expect(result, isA<Failure<ServerMessage>>());
    expect((result as Failure).error, sampleServerMessage);
  });

  test(
    'request returns Right with AuthDataDTO when API call succeeds',
    () async {
      final netKitResponse = NetKitResponse(
        isError: false,
        statusCode: 200,
        data: sampleAuthData.toJson(),
        headers: {},
        requestSpec: RequestSpec(pathOrUrl: '', method: HttpMethod.GET),
      );

      when(
        () => mockNetClient.execute(
          spec: any(named: 'spec'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
          requestCanceller: any(named: 'requestCanceller'),
          responseClassifier: any(named: 'responseClassifier'),
        ),
      ).thenAnswer((_) async => Result.success(netKitResponse));

      final result = await sut.request(tokenRefreshRequest);

      expect(result.isRight, true);
      final apiResponse = result.rightOrThrow;
      expect(apiResponse, isA<Success<AuthDataDTO>>());
      expect((apiResponse as Success).data, sampleAuthData);

      verify(
        () => mockNetClient.execute(
          spec: any(named: 'spec'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
          requestCanceller: any(named: 'requestCanceller'),
          responseClassifier: any(named: 'responseClassifier'),
        ),
      ).called(1);
    },
  );

  test('request returns Left with ApiError when API call throws', () async {
    final exception = TransportException(
      type: TransportExceptionType.CONNECTION_ERROR,
      request: RequestSpec(pathOrUrl: '', method: HttpMethod.GET),
    );

    when(
      () => mockNetClient.execute(
        spec: any(named: 'spec'),
        onSendProgress: any(named: 'onSendProgress'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
        requestCanceller: any(named: 'requestCanceller'),
        responseClassifier: any(named: 'responseClassifier'),
      ),
    ).thenAnswer((_) async => Result.error(exception));

    final result = await sut.request(tokenRefreshRequest);

    expect(result.isLeft, true);
    expect(result.leftOrThrow, isA<TransportError>());

    verify(
      () => mockNetClient.execute(
        spec: any(named: 'spec'),
        onSendProgress: any(named: 'onSendProgress'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
        requestCanceller: any(named: 'requestCanceller'),
        responseClassifier: any(named: 'responseClassifier'),
      ),
    ).called(1);
  });
}
