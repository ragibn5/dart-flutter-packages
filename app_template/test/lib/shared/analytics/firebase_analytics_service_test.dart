// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/shared/analytics/firebase_analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  const userId = 'userId123';
  const connectionEnabled = true;
  const userPropName = 'age';
  const userPropValue = '30';
  const eventName = 'flavor_config';
  const eventValue = {'name': 'dev', 'brightness': 'light', 'locale': 'en-US'};

  late _MockFirebaseAnalytics mockFirebaseAnalytics;

  late FirebaseAnalyticsService firebaseAnalyticsService;

  setUp(() {
    mockFirebaseAnalytics = _MockFirebaseAnalytics();
    firebaseAnalyticsService = FirebaseAnalyticsService.test(
      mockFirebaseAnalytics,
    );

    when(
      () => mockFirebaseAnalytics.setUserId(id: any(named: 'id')),
    ).thenAnswer((_) async {});
    when(
      () => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockFirebaseAnalytics.setUserProperty(
        name: any(named: 'name'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockFirebaseAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
  });

  test(
    '`setSessionData` should set user Id and analytics collection enabled status',
    () async {
      await firebaseAnalyticsService.setSessionData(
        userId,
        collectionEnabled: connectionEnabled,
      );

      verify(() => mockFirebaseAnalytics.setUserId(id: userId)).called(1);
      verify(
        () => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(
          connectionEnabled,
        ),
      ).called(1);
    },
  );

  test('`setUserProperty` should set correct user properties', () async {
    await firebaseAnalyticsService.setUserProperty(
      name: userPropName,
      value: userPropValue,
    );

    verify(
      () => mockFirebaseAnalytics.setUserProperty(
        name: userPropName,
        value: userPropValue,
      ),
    ).called(1);
  });

  test('`logEvent` should log correct event with correct value', () async {
    await firebaseAnalyticsService.logEvent(eventName, eventValue);

    verify(
      () => mockFirebaseAnalytics.logEvent(
        name: eventName,
        parameters: eventValue,
      ),
    ).called(1);
  });
}
