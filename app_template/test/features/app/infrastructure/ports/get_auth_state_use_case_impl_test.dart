import 'package:app_template/features/app/infrastructure/ports/get_auth_state_use_case_impl.dart';
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

  late GetAuthStateUseCaseImpl sut;

  setUp(() {
    mockGetAuthData = _MockGetAuthDataUseCase();

    sut = GetAuthStateUseCaseImpl(mockGetAuthData);
  });

  test(
    'Should return true when auth data is null (not authenticated)',
    () async {
      when(() => mockGetAuthData()).thenAnswer((_) async => null);

      final result = await sut();

      expect(result, isTrue);
    },
  );

  test(
    'Should return false when auth data is not null (authenticated)',
    () async {
      when(() => mockGetAuthData()).thenAnswer((_) async => authData);

      final result = await sut();

      expect(result, isFalse);
    },
  );
}
