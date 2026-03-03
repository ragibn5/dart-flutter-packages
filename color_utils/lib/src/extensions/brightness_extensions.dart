import 'package:flutter/painting.dart';

extension BrightnessExtension on Color {
  /// Returns a new color by darkening this color by the given amount.
  ///
  /// Amount must be >= 0.0 and <= 1.0
  Color darken(double amount) {
    assert(
      amount >= 0.0 && amount <= 1.0,
      '`amount` must be >= 0 and <= 1.0',
    );

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );

    return hslDark.toColor();
  }

  /// Returns a new color by lightening this color by the given amount.
  ///
  /// Amount must be >= 0.0 and <= 1.0
  Color lighten(double amount) {
    assert(
      amount >= 0 && amount <= 1,
      '`amount` must be >= 0 and <= 1.0',
    );

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );

    return hslLight.toColor();
  }
}
