import 'dart:async';

import 'package:app_template/features/app/infrastructure/ports/watch_auth_state_use_case_impl.dart';
import 'package:app_template/features/auth/domain/entities/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthDataService extends Mock implements AuthDataService {}

void main() {
  final authData = AuthData(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );

  late _MockAuthDataService mockAuthDataService;

  late WatchAuthStateUseCaseImpl sut;

  setUp(() {
    mockAuthDataService = _MockAuthDataService();

    sut = WatchAuthStateUseCaseImpl(mockAuthDataService);
  });

  test('Should emit true when auth data is not null', () async {
    when(
      () => mockAuthDataService.watchAuthData(),
    ).thenAnswer((_) => Stream.fromIterable([authData]));

    final result = await sut().first;

    expect(result, isTrue);
  });

  test('Should emit false when auth data is null', () async {
    when(
      () => mockAuthDataService.watchAuthData(),
    ).thenAnswer((_) => Stream.fromIterable([null]));

    final result = await sut().first;

    expect(result, isFalse);
  });
}
