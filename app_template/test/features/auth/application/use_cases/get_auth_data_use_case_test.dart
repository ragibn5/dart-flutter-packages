import 'package:app_template/features/auth/application/use_cases/get_auth_data_use_case.dart';
import 'package:app_template/features/auth/domain/entities/auth_data.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
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

  late _MockAuthDataRepository mockRepository;

  late GetAuthDataUseCase sut;

  setUp(() {
    mockRepository = _MockAuthDataRepository();

    sut = GetAuthDataUseCase(mockRepository);
  });

  test('Should return auth data when repository has data', () async {
    when(
      () => mockRepository.getCurrentAuthData(),
    ).thenAnswer((_) async => authData);

    final result = await sut();

    expect(result, authData);
  });

  test('Should return null when repository returns null', () async {
    when(
      () => mockRepository.getCurrentAuthData(),
    ).thenAnswer((_) async => null);

    final result = await sut();

    expect(result, isNull);
  });
}
