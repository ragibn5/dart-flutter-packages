// ignore_for_file: lines_longer_than_80_chars

import 'package:analytics/analytics.dart';
import 'package:app_template/features/app/application/use_cases/session_initializer_use_case.dart';
import 'package:app_template/features/auth/domain/entities/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:crashlytics/crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthDataService extends Mock implements AuthDataService {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockCrashlyticsService extends Mock implements CrashlyticsService {}

class _FakeAuthDataService extends Fake implements AuthDataService {}

void main() {
  const anonymousUserId = 'anonymous-user';

  final authData = AuthData(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );

  late _MockAuthDataService mockAuthDataService;
  late _MockAnalyticsService mockAnalyticsService;
  late _MockCrashlyticsService mockCrashlyticsService;

  late SessionInitializerUseCase sut;

  setUpAll(() {
    registerFallbackValue(_FakeAuthDataService());
  });

  setUp(() {
    mockAuthDataService = _MockAuthDataService();
    mockAnalyticsService = _MockAnalyticsService();
    mockCrashlyticsService = _MockCrashlyticsService();

    sut = SessionInitializerUseCase(
      mockAuthDataService,
      mockAnalyticsService,
      mockCrashlyticsService,
      anonymousUserId: anonymousUserId,
    );

    when(
      () => mockAnalyticsService.setSessionData(any(), collectionEnabled: true),
    ).thenAnswer((_) async {});
    when(
      () =>
          mockCrashlyticsService.setSessionData(any(), collectionEnabled: true),
    ).thenAnswer((_) async => authData);
  });

  test('Should set correct user id if auth data is not null', () async {
    when(
      () => mockAuthDataService.getCurrentAuthData(),
    ).thenAnswer((_) async => authData);

    await sut.initialize();

    verify(
      () => mockAnalyticsService.setSessionData(
        authData.userId,
        collectionEnabled: true,
      ),
    );
    verify(
      () => mockCrashlyticsService.setSessionData(
        authData.userId,
        collectionEnabled: true,
      ),
    );
  });

  test('Should set anonymous user if auth data is null', () async {
    when(
      () => mockAuthDataService.getCurrentAuthData(),
    ).thenAnswer((_) async => null);

    await sut.initialize();

    verify(
      () => mockAnalyticsService.setSessionData(
        anonymousUserId,
        collectionEnabled: true,
      ),
    );
    verify(
      () => mockCrashlyticsService.setSessionData(
        anonymousUserId,
        collectionEnabled: true,
      ),
    );
  });
}
