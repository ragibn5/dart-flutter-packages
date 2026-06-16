// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthDataRepository extends Mock implements AuthDataRepository {}

void main() {
  final authData = AuthData(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );

  late _MockAuthDataRepository mockAuthDataRepository;

  late AuthDataServiceImpl sut;

  setUpAll(() {
    registerFallbackValue(authData);
  });

  setUp(() {
    mockAuthDataRepository = _MockAuthDataRepository();

    sut = AuthDataServiceImpl(mockAuthDataRepository);

    when(
      () => mockAuthDataRepository.getCurrentAuthData(),
    ).thenAnswer((_) async => authData);
    when(
      () => mockAuthDataRepository.setCurrentAuthData(any()),
    ).thenAnswer((_) async {});
  });

  test(
    'getCurrentAuthData should call AuthDataRepository.getCurrentAuthData',
    () async {
      await sut.getCurrentAuthData();

      verify(() => mockAuthDataRepository.getCurrentAuthData()).called(1);
    },
  );

  test(
    'setCurrentAuthData should call AuthDataSource.setCurrentAuthData',
    () async {
      await sut.setCurrentAuthData(authData);

      verify(
        () => mockAuthDataRepository.setCurrentAuthData(authData),
      ).called(1);
    },
  );

  test('getAuthDataStream should return the auth data stream', () async {
    await sut.setCurrentAuthData(authData);

    verify(() => mockAuthDataRepository.setCurrentAuthData(authData)).called(1);
  });

  test(
    'refreshCurrentAuthData should return InvalidAuthStateForRefresh if not authenticated',
    () async {
      when(
        () => mockAuthDataRepository.getCurrentAuthData(),
      ).thenAnswer((_) async => null);

      final result = await sut.refreshCurrentAuthData();
      expect(result.isRight, true);
      final innerEither = result.rightOrThrow;
      expect(innerEither.isLeft, true);
      expect(innerEither.leftOrThrow, isA<InvalidAuthStateForRefresh>());
    },
  );
}
