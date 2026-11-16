import 'dart:ui';

import 'package:extended_color/src/utils/color_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('random', () {
    test('random should throw assertion error if opacity is out of range', () {
      expect(() => ColorBuilder.random(-0.1), throwsAssertionError);
      expect(() => ColorBuilder.random(1.1), throwsAssertionError);
    });

    test('randomShouldUseTheGivenOpacityIfItIsInRange', () {
      final color = ColorBuilder.random(0.5);

      expect(color.opacity, closeTo(0.5, 0.01));
    });
  });

  group('fromHex', () {
    test('fromHex should return the correct color from 6-character hex', () {
      final color = ColorBuilder.fromHex('#AABBCC');
      expect(color, equals(const Color(0xFFAABBCC)));
    });

    test('fromHex should return the correct color from 8-character hex', () {
      final color = ColorBuilder.fromHex('#80AABBCC');
      expect(color, equals(const Color(0x80AABBCC)));
    });

    test('fromHexShouldReplaceTheAlphaIfAnOpacityIsGivenWithAlpha', () {
      final color = ColorBuilder.fromHex('#80AABBCC', opacity: 0.25);

      expect(color, equals(const Color(0xFFAABBCC).withOpacity(0.25)));
    });

    test('fromHex should throw ArgumentError for invalid hex', () {
      expect(
        () => ColorBuilder.fromHex('#ZZZZZZ'),
        throwsArgumentError,
      );
    });

    test('fromHex should throw ArgumentError for unsupported hex length', () {
      expect(
        () => ColorBuilder.fromHex('#AABBCCDDEE'),
        throwsArgumentError,
      );
    });
  });
}
