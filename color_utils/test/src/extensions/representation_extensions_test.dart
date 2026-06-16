import 'package:color_utils/color_utils.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toHexString', () {
    test('toHexString should return the correct hex representation', () {
      const color = Color(0xFFAABBCC);
      expect(color.toHexString(), equals('#FFAABBCC'));
    });

    test(
      'toHexString should return the correct hex representation with alpha',
      () {
        const color = Color(0x80AABBCC);
        expect(color.toHexString(), equals('#80AABBCC'));
      },
    );
  });
}
