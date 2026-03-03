import 'package:color_utils/color_utils.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RepresentationUtils', () {
    test('fromHex should return the correct color from 6-character hex', () {
      final color = RepresentationUtils.fromHex('#AABBCC');
      expect(color, equals(const Color(0xFFAABBCC)));
    });

    test('fromHex should return the correct color from 8-character hex', () {
      final color = RepresentationUtils.fromHex('#80AABBCC');
      expect(color, equals(const Color(0x80AABBCC)));
    });

    test('fromHex should throw ArgumentError for invalid hex', () {
      expect(
        () => RepresentationUtils.fromHex('#ZZZZZZ'),
        throwsArgumentError,
      );
    });

    test('fromHex should throw ArgumentError for unsupported hex length', () {
      expect(
        () => RepresentationUtils.fromHex('#AABBCCDDEE'),
        throwsArgumentError,
      );
    });
  });
}
