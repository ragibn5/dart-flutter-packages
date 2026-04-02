// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/auth/presentation/bloc/login_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthDataService extends Mock implements AuthDataService {}

void main() {
  final authData = AuthData(
    userId: 'username',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
    refreshTokenExpiry: DateTime.now().add(const Duration(days: 3)),
  );

  late _MockAuthDataService mockAuthDataService;

  late LoginBloc sut;

  setUpAll(() {
    registerFallbackValue(authData);
  });

  setUp(() {
    mockAuthDataService = _MockAuthDataService();

    sut = LoginBloc(mockAuthDataService);

    when(
      () => mockAuthDataService.setCurrentAuthData(any()),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    sut.close();
  });

  test('Initial state is LoginInitial', () {
    expect(sut.state, isA<LoginInitial>());
  });

  blocTest<LoginBloc, LoginState>(
    'Emits LoginInProgress -> LoginError when AuthDataService throws exception',
    build: () {
      when(
        () => mockAuthDataService.setCurrentAuthData(any()),
      ).thenThrow(Exception('test_error'));
      return sut;
    },
    act: (bloc) => bloc.add(LoginRequested(username: 'test_user')),
    expect: () => [isA<LoginInProgress>(), isA<LoginError>()],
  );

  blocTest<LoginBloc, LoginState>(
    'Emits LoginInProgress -> LoginComplete when AuthDataService DOES NOT throw any exception',
    build: () {
      when(
        () => mockAuthDataService.setCurrentAuthData(any()),
      ).thenAnswer((_) async => authData);
      return sut;
    },
    act: (bloc) => bloc.add(LoginRequested(username: 'test_user')),
    expect: () => [isA<LoginInProgress>(), isA<LoginComplete>()],
  );
}
