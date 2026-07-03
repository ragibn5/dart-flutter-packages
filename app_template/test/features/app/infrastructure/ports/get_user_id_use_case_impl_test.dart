import 'package:app_template/features/app/infrastructure/ports/get_user_id_use_case_impl.dart';
import 'package:app_template/features/auth/application/use_cases/get_auth_data_use_case.dart';
import 'package:app_template/features/auth/domain/entities/auth_data.dart';
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

  late _MockGetAuthDataUseCase mockGetAuthDataUseCase;

  late GetUserIdUseCaseImpl sut;

  setUp(() {
    mockGetAuthDataUseCase = _MockGetAuthDataUseCase();

    sut = GetUserIdUseCaseImpl(mockGetAuthDataUseCase);
  });

  test('Should return null when auth data is null', () async {
    when(() => mockGetAuthDataUseCase()).thenAnswer((_) async => null);

    final result = await sut();

    expect(result, isNull);
  });

  test('Should return userId when auth data is available', () async {
    when(() => mockGetAuthDataUseCase()).thenAnswer((_) async => authData);

    final result = await sut();

    expect(result, 'userId');
  });
}
