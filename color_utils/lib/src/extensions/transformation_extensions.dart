import 'package:flutter/painting.dart';

extension TransformationExtension on Color {
  /// Returns a new color by inverting the given color.
  Color invert(double opacity) {
    assert(
      opacity >= 0.0 && opacity <= 1.0,
      '`opacity` must be >= 0 and <= 1.0',
    );
    return Color.fromRGBO(
      255 - red,
      255 - green,
      255 - blue,
      opacity,
    );
  }

  /// Returns the complementary color of this color.
  Color get complementary {
    final hsl = HSLColor.fromColor(this);
    return hsl.withHue((hsl.hue + 180) % 360).toColor();
  }

  /// Determine if it is more close to `Dark`.
  bool get isDark {
    return (red * 0.299 + green * 0.587 + blue * 0.114) < 128;
  }

  /// Determine if it is more close to `Light`.
  bool get isLight {
    return !isDark;
  }
}
