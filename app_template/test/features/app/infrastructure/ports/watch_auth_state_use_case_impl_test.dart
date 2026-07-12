import 'dart:async';

import 'package:app_template/features/app/infrastructure/ports/watch_auth_state_use_case_impl.dart';
import 'package:app_template/features/auth/application/use_cases/watch_auth_data_use_case.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchAuthDataUseCase extends Mock implements WatchAuthDataUseCase {}

void main() {
  final authData = AuthData(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );

  late _MockWatchAuthDataUseCase mockWatchAuthData;

  late WatchAuthStateUseCaseImpl sut;

  setUp(() {
    mockWatchAuthData = _MockWatchAuthDataUseCase();

    sut = WatchAuthStateUseCaseImpl(mockWatchAuthData);
  });

  test('Should emit true when auth data is not null', () async {
    when(
      () => mockWatchAuthData(),
    ).thenAnswer((_) => Stream.fromIterable([authData]));

    final result = await sut().first;

    expect(result, isTrue);
  });

  test('Should emit false when auth data is null', () async {
    when(
      () => mockWatchAuthData(),
    ).thenAnswer((_) => Stream.fromIterable([null]));

    final result = await sut().first;

    expect(result, isFalse);
  });
}
