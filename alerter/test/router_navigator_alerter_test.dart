import 'package:alerter/alerter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNavigatorKey extends Mock implements GlobalKey<NavigatorState> {}

void main() {
  late _MockNavigatorKey mockNavigatorKey;
  late RouterNavigatorAlerter sut;

  setUp(() {
    mockNavigatorKey = _MockNavigatorKey();
    sut = RouterNavigatorAlerter(mockNavigatorKey);
  });

  group('getCurrentContext', () {
    test('throws StateError when navigator key has no current context', () {
      when(() => mockNavigatorKey.currentContext).thenReturn(null);

      expect(
        () => sut.showTextAlert(
          AlertData.error(title: 'Title', message: 'Message'),
          [],
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
