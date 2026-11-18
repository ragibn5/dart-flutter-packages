import 'package:content_io_android/src/models/thumbnail_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shouldThrowAssertionErrorIfWidthIsNotPositive', () {
    expect(() => ThumbnailSize(width: 0, height: 128), throwsAssertionError);
  });

  test('shouldThrowAssertionErrorIfHeightIsNotPositive', () {
    expect(() => ThumbnailSize(width: 256, height: 0), throwsAssertionError);
  });
}
