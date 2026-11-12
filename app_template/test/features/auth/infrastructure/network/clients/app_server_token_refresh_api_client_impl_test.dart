import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/infrastructure/network/clients/app_server_token_refresh_api_client_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_models/net_models.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../../helpers/fake_http_client_adapter.dart';

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

  late FakeHttpClientAdapter adapter;
  late AppServerTokenRefreshApiClientImpl sut;

  setUp(() {
    adapter = FakeHttpClientAdapter((_) => ResponseBody.fromString('', 200));
    sut = AppServerTokenRefreshApiClientImpl(fakeDio(adapter));
  });

  test('sendShouldGetTheRefreshPathWithTheRefreshTokenIfCalled', () async {
    await sut.send(fakeDio(adapter), tokenRefreshRequest);

    final request = adapter.requests.single;
    expect(request.path, path);
    expect(request.method, 'GET');
    expect(request.data, tokenRefreshRequest.toJson());
  });

  test('decodeResponseShouldReturnTheAuthDataIfTheResponseSucceeded', () {
    final response = Response<Object?>(
      requestOptions: RequestOptions(),
      statusCode: 200,
      data: sampleAuthData.toJson(),
    );

    final result = sut.decodeResponse(response);

    expect(result, isA<SuccessResponse<AuthDataDTO>>());
    expect((result as SuccessResponse).data, sampleAuthData);
  });

  test('decodeResponseShouldReturnAFailureIfTheResponseFailed', () {
    final response = Response<Object?>(
      requestOptions: RequestOptions(),
      statusCode: 400,
      data: sampleServerMessage.toJson(),
    );

    final result = sut.decodeResponse(response);

    expect(result, isA<FailureResponse<ServerMessage>>());
    expect((result as FailureResponse).error, sampleServerMessage);
  });
}
