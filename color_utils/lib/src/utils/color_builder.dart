import 'dart:math';

import 'package:flutter/painting.dart';

final class ColorBuilder {
  ColorBuilder._();

  static Color random(double opacity) {
    assert(
      opacity >= 0.0 && opacity <= 1.0,
      '`opacity` must be >= 0 and <= 1.0',
    );

    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      opacity,
    );
  }

  static Color fromHex(String hexColor, {double? opacity}) {
    final colorHex = hexColor.replaceAll('#', '');

    final colorInt = int.tryParse(colorHex, radix: 16);
    if (colorInt == null) {
      throw ArgumentError('Invalid hex value');
    }

    if (colorHex.length == 6) {
      return Color(colorInt).withOpacity(opacity ?? 1.0);
    } else if (colorHex.length >= 7 && colorHex.length <= 8) {
      if (opacity == null) {
        return Color(colorInt);
      }

      final colorHexWithoutOpacity =
          colorHex.substring(colorHex.length - 6).padLeft(8, '0');
      return Color(int.parse(colorHexWithoutOpacity, radix: 16))
          .withOpacity(opacity);
    } else {
      throw ArgumentError(
        'Unsupported color hex: '
        'Must be 6 (non-alpha) or 8(with-alpha) characters long',
      );
    }
  }
}
