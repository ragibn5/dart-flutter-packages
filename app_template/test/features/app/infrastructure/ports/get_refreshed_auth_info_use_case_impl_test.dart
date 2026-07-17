import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/app/infrastructure/ports/get_refreshed_auth_info_use_case_impl.dart';
import 'package:app_template/features/auth/application/use_cases/refresh_auth_data_use_case.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:core_models/core_models.dart';
import 'package:functionals/functionals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRefreshAuthDataUseCase extends Mock
    implements RefreshAuthDataUseCase {}

void main() {
  final refreshedAuthData = AuthData(
    userId: 'userId',
    accessToken: 'newAccessToken',
    refreshToken: 'newRefreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );

  late _MockRefreshAuthDataUseCase mockRefreshAuthData;

  late GetRefreshedAuthInfoUseCaseImpl sut;

  setUp(() {
    mockRefreshAuthData = _MockRefreshAuthDataUseCase();

    sut = GetRefreshedAuthInfoUseCaseImpl(mockRefreshAuthData);
  });

  test('Should return AuthInfo on successful refresh', () async {
    when(
      () => mockRefreshAuthData(),
    ).thenAnswer((_) async => Right(Right(refreshedAuthData)));

    final result = await sut();

    expect(result, isA<AuthInfo>());
    expect(result!.accessToken, refreshedAuthData.accessToken);
    expect(result!.refreshToken, refreshedAuthData.refreshToken);
    expect(result!.accessTokenExpiry, refreshedAuthData.accessTokenExpiry);
    expect(result!.refreshTokenExpiry, refreshedAuthData.refreshTokenExpiry);
  });

  test('Should return null when refresh returns Left (ApiError)', () async {
    when(
      () => mockRefreshAuthData(),
    ).thenAnswer((_) async => Left(const CancellationError(source: 'test')));

    final result = await sut();

    expect(result, isNull);
  });

  test(
    'Should return null when refresh returns inner Left (domain error)',
    () async {
      when(
        () => mockRefreshAuthData(),
      ).thenAnswer((_) async => Right(Left(InvalidRefreshToken())));

      final result = await sut();

      expect(result, isNull);
    },
  );
}
