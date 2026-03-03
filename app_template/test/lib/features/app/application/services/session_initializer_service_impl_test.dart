// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/app/application/services/session_initializer_service_impl.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/shared/analytics/analytics_service.dart';
import 'package:app_template/shared/crashlytics/crashlytics_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthDataService extends Mock implements AuthDataService {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockCrashlyticsService extends Mock implements CrashlyticsService {}

class _FakeAuthDataService extends Fake implements AuthDataService {}

void main() {
  const anonymousUserId = 'anonymous';
  final authData = AuthData(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );

  late _MockAuthDataService authDataService;
  late _MockAnalyticsService analyticsService;
  late _MockCrashlyticsService crashlyticsService;

  late SessionInitializerServiceImpl sessionInitializerServiceImpl;

  setUpAll(() {
    registerFallbackValue(_FakeAuthDataService());
  });

  setUp(() {
    authDataService = _MockAuthDataService();
    analyticsService = _MockAnalyticsService();
    crashlyticsService = _MockCrashlyticsService();
    sessionInitializerServiceImpl = SessionInitializerServiceImpl.test(
      authDataService,
      analyticsService,
      crashlyticsService,
      anonymousUserId: anonymousUserId,
    );

    when(
      () => analyticsService.setSessionData(any(), enabled: true),
    ).thenAnswer((_) async {});
    when(
      () => crashlyticsService.setSessionData(any(), enabled: true),
    ).thenAnswer((_) async => authData);
  });

  test('Should set correct user id if auth data is not null', () async {
    when(
      () => authDataService.getCurrentAuthData(),
    ).thenAnswer((_) async => authData);

    await sessionInitializerServiceImpl.initialize();

    verify(
      () => analyticsService.setSessionData(authData.userId, enabled: true),
    );
    verify(
      () => crashlyticsService.setSessionData(authData.userId, enabled: true),
    );
  });

  test('Should set anonymous user if auth data is null', () async {
    when(
      () => authDataService.getCurrentAuthData(),
    ).thenAnswer((_) async => null);

    await sessionInitializerServiceImpl.initialize();

    verify(
      () => analyticsService.setSessionData(anonymousUserId, enabled: true),
    );
    verify(
      () => crashlyticsService.setSessionData(anonymousUserId, enabled: true),
    );
  });
}
