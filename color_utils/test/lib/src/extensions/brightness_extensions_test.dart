import 'package:color_utils/color_utils.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('darken', () {
    test('darken should return a darker color', () {
      const color = Color(0xFF808080);
      final darkenedColor = color.darken(0.2);

      expect(darkenedColor, isNot(color));
      expect(
        darkenedColor.computeLuminance(),
        lessThan(color.computeLuminance()),
      );
    });

    test('darken should clamp to black if amount is too high', () {
      const color = Color(0xFF808080);
      final darkenedColor = color.darken(1);

      expect(
        darkenedColor,
        equals(const Color(0xFF000000)),
      );
    });

    test('darken should throw assertion error if amount is out of range', () {
      const color = Color(0xFF808080);

      expect(() => color.darken(-0.1), throwsAssertionError);
      expect(() => color.darken(1.1), throwsAssertionError);
    });
  });

  group('lighten', () {
    test('lighten should return a lighter color', () {
      const color = Color(0xFF808080);
      final lightenedColor = color.lighten(0.2);

      expect(lightenedColor, isNot(color));
      expect(
        lightenedColor.computeLuminance(),
        greaterThan(color.computeLuminance()),
      );
    });

    test('lighten should clamp to white if amount is too high', () {
      const color = Color(0xFF808080);
      final lightenedColor = color.lighten(1);

      expect(
        lightenedColor,
        equals(const Color(0xFFFFFFFF)),
      );
    });

    test('lighten should throw assertion error if amount is out of range', () {
      const color = Color(0xFF808080);

      expect(() => color.lighten(-0.1), throwsAssertionError);
      expect(() => color.lighten(1.1), throwsAssertionError);
    });
  });
}
