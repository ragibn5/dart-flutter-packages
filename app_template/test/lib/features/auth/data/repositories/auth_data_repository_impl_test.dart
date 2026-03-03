// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:io';

import 'package:app_template/core/models/api_error.dart';
import 'package:app_template/core/models/api_result.dart';
import 'package:app_template/core/models/server_message.dart';
import 'package:app_template/features/auth/data/mappers/auth_data_mapper.dart';
import 'package:app_template/features/auth/data/mappers/auth_refresh_error_mapper.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/data/repositories/auth_data_repository_impl.dart';
import 'package:app_template/features/auth/data/sources/local_auth_data_source.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthDataMapper extends Mock implements AuthDataMapper {}

class _MockAuthDataRefreshErrorMapper extends Mock
    implements AuthRefreshErrorMapper {}

class _MockLocalAuthDataDataSource extends Mock
    implements LocalAuthDataSource {}

class _MockRemoteAuthDataDataSource extends Mock
    implements RemoteAuthDataSource {}

class _MockAuthDataStreamController extends Mock
    implements StreamController<AuthData?> {}

class _MockAuthDataStream extends Mock implements Stream<AuthData?> {}

extension _AuthDataDTOToEntity on AuthDataDTO {
  AuthData toEntity() {
    return AuthData(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiry: accessTokenExpiry,
      refreshTokenExpiry: refreshTokenExpiry,
    );
  }
}

void main() {
  const tokenRefreshRequest = TokenRefreshRequest(refreshToken: 'refreshToken');
  final authDataDTO = AuthDataDTO(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );
  final refreshedAuthDataDTO = AuthDataDTO(
    userId: 'userId',
    accessToken: 'accessTokenNew',
    refreshToken: 'refreshTokenNew',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );
  final authData = authDataDTO.toEntity();
  final refreshedAuthData = refreshedAuthDataDTO.toEntity();
  final succeededAuthRefreshResult =
      ApiResult<ApiError<ServerError<ServerMessage>>, AuthDataDTO>.success(
        refreshedAuthDataDTO,
      );
  final authRefreshDataError = ApiError.fromServerError(
    const ServerError(
      statusCode: HttpStatus.unauthorized,
      errorResponse: ServerMessage(code: 'refresh_token_expired'),
    ),
  );
  final authRefreshDomainError = ApiError.fromServerError(
    InvalidRefreshToken(),
  );
  final failedAuthRefreshResult =
      ApiResult<ApiError<ServerError<ServerMessage>>, AuthDataDTO>.failure(
        authRefreshDataError,
      );

  late _MockAuthDataMapper mockAuthDataMapper;
  late _MockAuthDataRefreshErrorMapper mockAuthDataRefreshErrorMapper;
  late _MockAuthDataStreamController mockAuthDataStreamController;
  late _MockLocalAuthDataDataSource mockLocalAuthDataSource;
  late _MockRemoteAuthDataDataSource mockRemoteAuthDataSource;
  late _MockAuthDataStream mockAuthDataStream;

  late AuthDataRepositoryImpl authDataRepositoryImpl;

  setUpAll(() {
    registerFallbackValue(authData);
    registerFallbackValue(authDataDTO);
    registerFallbackValue(tokenRefreshRequest);
    registerFallbackValue(authRefreshDataError);
  });

  setUp(() {
    mockAuthDataMapper = _MockAuthDataMapper();
    mockAuthDataRefreshErrorMapper = _MockAuthDataRefreshErrorMapper();
    mockAuthDataStreamController = _MockAuthDataStreamController();
    mockLocalAuthDataSource = _MockLocalAuthDataDataSource();
    mockRemoteAuthDataSource = _MockRemoteAuthDataDataSource();
    mockAuthDataStream = _MockAuthDataStream();

    authDataRepositoryImpl = AuthDataRepositoryImpl.test(
      mockAuthDataMapper,
      mockAuthDataRefreshErrorMapper,
      mockAuthDataStreamController,
      mockLocalAuthDataSource,
      mockRemoteAuthDataSource,
    );

    when(
      () => mockAuthDataMapper.convertDataToDomain(authDataDTO),
    ).thenAnswer((_) => authData);
    when(
      () => mockAuthDataMapper.convertDomainToData(authData),
    ).thenAnswer((_) => authDataDTO);
    when(
      () => mockAuthDataMapper.convertDataToDomain(refreshedAuthDataDTO),
    ).thenAnswer((_) => refreshedAuthData);
    when(
      () => mockAuthDataMapper.convertDomainToData(refreshedAuthData),
    ).thenAnswer((_) => refreshedAuthDataDTO);
    when(
      () => mockAuthDataRefreshErrorMapper.convertDataToDomain(
        authRefreshDataError,
      ),
    ).thenAnswer((_) => authRefreshDomainError);
    when(
      () => mockLocalAuthDataSource.getCurrentAuthData(),
    ).thenAnswer((_) async => authDataDTO);
    when(
      () => mockLocalAuthDataSource.setCurrentAuthData(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockAuthDataStreamController.stream,
    ).thenAnswer((_) => mockAuthDataStream);
    when(
      () => mockAuthDataStreamController.add(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockAuthDataStreamController.close(),
    ).thenAnswer((_) async => {});
  });

  tearDown(() {
    authDataRepositoryImpl.dispose();
  });

  test(
    'getCurrentAuthData should return null if data-source returns null',
    () async {
      when(
        () => mockLocalAuthDataSource.getCurrentAuthData(),
      ).thenAnswer((_) async => null);

      final result = await authDataRepositoryImpl.getCurrentAuthData();

      expect(result, null);
      verify(() => mockLocalAuthDataSource.getCurrentAuthData()).called(1);
      verifyNever(() => mockAuthDataMapper.convertDataToDomain(any()));
    },
  );

  test(
    'getCurrentAuthData should returns non-null AuthData if data-source returns valid non-null DTO',
    () async {
      when(
        () => mockLocalAuthDataSource.getCurrentAuthData(),
      ).thenAnswer((_) async => authDataDTO);

      final result = await authDataRepositoryImpl.getCurrentAuthData();

      expect(result, authData);
      verify(() => mockLocalAuthDataSource.getCurrentAuthData()).called(1);
      verify(
        () => mockAuthDataMapper.convertDataToDomain(authDataDTO),
      ).called(1);
    },
  );

  test(
    'setCurrentAuthData(null) should add to the auth data stream and call AuthDataSource.setCurrentAuthData with null',
    () async {
      // When NULL
      await authDataRepositoryImpl.setCurrentAuthData(null);

      verify(() => mockAuthDataStreamController.add(null)).called(1);
      verifyNever(() => mockAuthDataMapper.convertDomainToData(authData));
      verify(() => mockLocalAuthDataSource.setCurrentAuthData(null)).called(1);
    },
  );

  test(
    'setCurrentAuthData(authData) should add to the auth data stream and call AuthDataSource.setCurrentAuthData with proper data',
    () async {
      await authDataRepositoryImpl.setCurrentAuthData(authData);

      verify(() => mockAuthDataStreamController.add(authData)).called(1);
      verify(() => mockAuthDataMapper.convertDomainToData(authData)).called(1);
      verify(
        () => mockLocalAuthDataSource.setCurrentAuthData(authDataDTO),
      ).called(1);
    },
  );

  test(
    'refreshCurrentAuthData success, emits, persists, and returns refreshed domain auth data',
    () async {
      when(
        () => mockRemoteAuthDataSource.getRefreshedAuthData(any()),
      ).thenAnswer((_) async => succeededAuthRefreshResult);

      final result = await authDataRepositoryImpl.refreshCurrentAuthData(
        authData,
      );

      // Correct request
      verify(
        () => mockRemoteAuthDataSource.getRefreshedAuthData(
          TokenRefreshRequest(refreshToken: authData.refreshToken),
        ),
      ).called(1);

      // Mapping
      verify(
        () => mockAuthDataMapper.convertDataToDomain(refreshedAuthDataDTO),
      ).called(1);

      // Side effects
      verify(
        () => mockAuthDataStreamController.add(refreshedAuthData),
      ).called(1);
      verify(
        () => mockLocalAuthDataSource.setCurrentAuthData(refreshedAuthDataDTO),
      ).called(1);

      // Return
      expect(result.isSuccess, true);
      expect(result.dataOrNull, refreshedAuthData);
    },
  );

  test(
    'On failure, refreshCurrentAuthData should return failure result',
    () async {
      when(
        () => mockRemoteAuthDataSource.getRefreshedAuthData(any()),
      ).thenAnswer((_) async => failedAuthRefreshResult);

      final result = await authDataRepositoryImpl.refreshCurrentAuthData(
        authData,
      );

      // Correct request
      verify(
        () => mockRemoteAuthDataSource.getRefreshedAuthData(
          TokenRefreshRequest(refreshToken: authData.refreshToken),
        ),
      ).called(1);

      // Mapping
      verify(
        () => mockAuthDataRefreshErrorMapper.convertDataToDomain(any()),
      ).called(1);

      // Return
      expect(result.isError, true);
      expect(result.errorOrNull, authRefreshDomainError);
    },
  );

  test('getAuthDataStream should return the auth data stream', () async {
    final result = authDataRepositoryImpl.getAuthDataStream();

    expect(result, mockAuthDataStream);
  });

  test('Dispose should close the auth data stream', () async {
    authDataRepositoryImpl.dispose();

    verify(() => mockAuthDataStreamController.close()).called(1);
  });
}
