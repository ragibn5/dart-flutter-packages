import 'package:app_template/features/auth/application/use_cases/set_auth_data_use_case.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
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

  late SetAuthDataUseCase sut;

  setUpAll(() {
    registerFallbackValue(authData);
  });

  setUp(() {
    mockRepository = _MockAuthDataRepository();

    sut = SetAuthDataUseCase(mockRepository);

    when(
      () => mockRepository.setCurrentAuthData(any()),
    ).thenAnswer((_) async {});
  });

  test('Should set auth data via repository', () async {
    await sut(authData);

    verify(() => mockRepository.setCurrentAuthData(authData)).called(1);
  });

  test('Should clear auth data via repository when null', () async {
    await sut(null);

    verify(() => mockRepository.setCurrentAuthData(null)).called(1);
  });
}
