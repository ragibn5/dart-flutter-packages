// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source_impl.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_client.dart';
import 'package:core_models/core_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppServerTokenRefreshApiClient extends Mock
    implements AppServerTokenRefreshApiClient {}

void main() {
  const tokenRefreshRequest = TokenRefreshRequest(refreshToken: 'refreshToken');
  final authDataDTO = AuthDataDTO(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );
  final clientResponse = Right(
    Success(data: authDataDTO, statusCode: 200, headers: null),
  );

  late _MockAppServerTokenRefreshApiClient mockApiClient;

  late RemoteAuthDataSourceImpl sut;

  setUpAll(() {
    registerFallbackValue(tokenRefreshRequest);
  });

  setUp(() {
    mockApiClient = _MockAppServerTokenRefreshApiClient();

    sut = RemoteAuthDataSourceImpl(mockApiClient);
  });

  test(
    'getRefreshedAuthData should call client.getRefreshedAuthData',
    () async {
      when(
        () => mockApiClient.request(tokenRefreshRequest),
      ).thenAnswer((_) async => clientResponse);

      final result = await sut.getRefreshedAuthData(tokenRefreshRequest);

      verify(() => mockApiClient.request(tokenRefreshRequest)).called(1);
      expect(result.isRight, true);
      final innerEither = result.rightOrThrow;
      expect(innerEither.isRight, true);
      expect(innerEither.rightOrThrow, authDataDTO);
    },
  );
}
