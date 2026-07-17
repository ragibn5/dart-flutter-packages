import 'package:app_template/features/auth/application/use_cases/refresh_auth_data_use_case.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:core_models/core_models.dart';
import 'package:functionals/functionals.dart';
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
  final refreshedAuthData = AuthData(
    userId: 'userId',
    accessToken: 'accessTokenNew',
    refreshToken: 'refreshTokenNew',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );

  late _MockAuthDataRepository mockRepository;

  late RefreshAuthDataUseCase sut;

  setUpAll(() {
    registerFallbackValue(authData);
  });

  setUp(() {
    mockRepository = _MockAuthDataRepository();

    sut = RefreshAuthDataUseCase(mockRepository);

    when(
      () => mockRepository.getCurrentAuthData(),
    ).thenAnswer((_) async => authData);
  });

  test(
    'Should return InvalidAuthStateForRefresh when no current auth data exists',
    () async {
      when(
        () => mockRepository.getCurrentAuthData(),
      ).thenAnswer((_) async => null);

      final result = await sut();

      result.fold(
        onLeft: (_) => fail('Expected a domain error'),
        onRight: (inner) => inner.fold(
          onLeft: (error) => expect(error, isA<InvalidAuthStateForRefresh>()),
          onRight: (_) => fail('Expected a domain error'),
        ),
      );
    },
  );

  test('Should return refreshed auth data on success', () async {
    when(
      () => mockRepository.refreshCurrentAuthData(authData),
    ).thenAnswer((_) async => Right(Right(refreshedAuthData)));

    final result = await sut();

    result.fold(
      onLeft: (_) => fail('Expected success'),
      onRight: (inner) => inner.fold(
        onLeft: (_) => fail('Expected success'),
        onRight: (data) => expect(data, refreshedAuthData),
      ),
    );
  });

  test(
    'Should return API error when refresh fails with transport error',
    () async {
      when(() => mockRepository.refreshCurrentAuthData(authData)).thenAnswer(
        (_) async => Left(
          const UnexpectedError(cause: 'error', stackTrace: StackTrace.empty),
        ),
      );

      final result = await sut();

      result.fold(
        onLeft: (error) => expect(error, isA<UnexpectedError>()),
        onRight: (_) => fail('Expected an API error'),
      );
    },
  );

  test('Should return domain error on server error', () async {
    when(
      () => mockRepository.refreshCurrentAuthData(authData),
    ).thenAnswer((_) async => Right(Left(InvalidRefreshToken())));

    final result = await sut();

    result.fold(
      onLeft: (_) => fail('Expected a domain error'),
      onRight: (inner) => inner.fold(
        onLeft: (error) => expect(error, isA<InvalidRefreshToken>()),
        onRight: (_) => fail('Expected a domain error'),
      ),
    );
  });
}
