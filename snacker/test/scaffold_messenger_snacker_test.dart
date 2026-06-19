import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snacker/snacker.dart';

class _MockScaffoldMessengerKey extends Mock
    implements GlobalKey<ScaffoldMessengerState> {}

void main() {
  group('getCurrentContext', () {
    test('throws StateError when key has no currentState', () {
      final mockKey = _MockScaffoldMessengerKey();
      when(() => mockKey.currentState).thenReturn(null);

      final sut = ScaffoldMessengerSnacker(mockKey);

      expect(
        () => sut.showTextSnack(SnackData.info(message: 'test')),
        throwsA(isA<StateError>()),
      );
    });
  });
}
