import 'package:color_utils/color_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RandomizationUtils', () {
    test('random should throw assertion error if opacity is out of range', () {
      expect(() => RandomizationUtils.random(-0.1), throwsAssertionError);
      expect(() => RandomizationUtils.random(1.1), throwsAssertionError);
    });
  });
}
