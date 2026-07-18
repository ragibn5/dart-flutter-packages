import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/app/infrastructure/ports/get_auth_info_use_case_impl.dart';
import 'package:app_template/features/auth/application/use_cases/get_auth_data_use_case.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetAuthDataUseCase extends Mock implements GetAuthDataUseCase {}

void main() {
  final authData = AuthData(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );

  late _MockGetAuthDataUseCase mockGetAuthData;

  late GetAuthInfoUseCaseImpl sut;

  setUp(() {
    mockGetAuthData = _MockGetAuthDataUseCase();

    sut = GetAuthInfoUseCaseImpl(mockGetAuthData);
  });

  test('Should return null when auth data is null', () async {
    when(() => mockGetAuthData()).thenAnswer((_) async => null);

    final result = await sut();

    expect(result, isNull);
  });

  test('Should return AuthInfo when auth data is not null', () async {
    when(() => mockGetAuthData()).thenAnswer((_) async => authData);

    final result = await sut();

    expect(result, isA<AuthInfo>());
    expect(result!.accessToken, authData.accessToken);
    expect(result.refreshToken, authData.refreshToken);
    expect(result.accessTokenExpiry, authData.accessTokenExpiry);
    expect(result.refreshTokenExpiry, authData.refreshTokenExpiry);
  });
}
