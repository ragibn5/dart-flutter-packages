import 'package:color_utils/color_utils.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorExtension', () {
    test('invert should return the inverted color', () {
      const color = Color.fromRGBO(0, 0, 255, 1);
      final invertedColor = color.invert(1);

      expect(invertedColor, equals(const Color.fromRGBO(255, 255, 0, 1)));
    });

    test('invert should throw assertion error if opacity is out of range', () {
      const color = Color(0xFF0000FF);

      expect(() => color.invert(-0.1), throwsAssertionError);
      expect(() => color.invert(1.1), throwsAssertionError);
    });

    test('complementary should return the complementary color', () {
      const color = Color(0xFFFF0000);
      final complementaryColor = color.complementary;

      expect(complementaryColor, equals(const Color(0xFF00FFFF)));
    });

    test('isDark should return true for dark colors', () {
      const darkColor = Color(0xFF000000);
      expect(darkColor.isDark, isTrue);
    });

    test('isDark should return false for light colors', () {
      const lightColor = Color(0xFFFFFFFF);
      expect(lightColor.isDark, isFalse);
    });

    test('isLight should return true for light colors', () {
      const lightColor = Color(0xFFFFFFFF);
      expect(lightColor.isLight, isTrue);
    });

    test('isLight should return false for dark colors', () {
      const darkColor = Color(0xFF000000);
      expect(darkColor.isLight, isFalse);
    });
  });
}
