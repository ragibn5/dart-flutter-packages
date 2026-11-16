import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/thumbnail_size.dart';

void main() {
  test('shouldThrowAssertionErrorIfWidthIsNotPositive', () {
    expect(() => ThumbnailSize(width: 0, height: 128), throwsAssertionError);
  });

  test('shouldThrowAssertionErrorIfHeightIsNotPositive', () {
    expect(() => ThumbnailSize(width: 256, height: 0), throwsAssertionError);
  });
}
