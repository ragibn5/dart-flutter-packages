// ignore_for_file: lines_longer_than_80_chars

import 'package:analykit/src/firebase_analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  const userId = 'userId123';
  const eventName = 'flavor_config';
  const eventValue = {'name': 'dev', 'brightness': 'light', 'locale': 'en-US'};

  late _MockFirebaseAnalytics mockFirebaseAnalytics;

  late FirebaseAnalyticsService sut;

  setUp(() {
    mockFirebaseAnalytics = _MockFirebaseAnalytics();

    sut = FirebaseAnalyticsService(mockFirebaseAnalytics);

    when(
      () => mockFirebaseAnalytics.setUserId(id: any(named: 'id')),
    ).thenAnswer((_) async {});
    when(
      () => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockFirebaseAnalytics.setConsent(
        analyticsStorageConsentGranted: any(
          named: 'analyticsStorageConsentGranted',
        ),
      ),
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

  test('initializeShouldCompleteIfCalled', () async {
    await expectLater(sut.initialize(), completes);
  });

  test('setUserIdShouldSetTheUserIdIfGivenOne', () async {
    await sut.setUserId(userId);

    verify(() => mockFirebaseAnalytics.setUserId(id: userId)).called(1);
  });

  test('setUserIdShouldClearTheUserIdIfGivenNull', () async {
    await sut.setUserId(null);

    verify(() => mockFirebaseAnalytics.setUserId()).called(1);
  });

  test('setCollectionEnabledShouldSetCollectionAndConsentIfCalled', () async {
    await sut.setCollectionEnabled(enabled: false);

    verify(
      () => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(false),
    ).called(1);
    verify(
      () => mockFirebaseAnalytics.setConsent(
        analyticsStorageConsentGranted: false,
      ),
    ).called(1);
  });

  test('logEventShouldLogTheEventWithItsParametersIfCalled', () async {
    await sut.logEvent(eventName, eventValue);

    verify(
      () => mockFirebaseAnalytics.logEvent(
        name: eventName,
        parameters: eventValue,
      ),
    ).called(1);
  });
}
