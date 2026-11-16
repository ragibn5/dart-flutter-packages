import 'package:extended_color/extended_color.dart';
import 'package:flutter/painting.dart';

void main() {
  // Build a color from a hex string, with or without `#` and an alpha byte.
  final brand = ColorBuilder.fromHex('#1E88E5');
  final faded = ColorBuilder.fromHex('1E88E5', opacity: 0.5);

  // Adjust its brightness, or derive related colors.
  final darker = brand.darken(0.2);
  final lighter = brand.lighten(0.2);
  final complementary = brand.complementary;

  // Pick a readable text color for it.
  final textColor =
      brand.isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

  print('brand:         ${brand.toHexString()}');
  print('faded:         ${faded.toHexString()}');
  print('darker:        ${darker.toHexString()}');
  print('lighter:       ${lighter.toHexString()}');
  print('complementary: ${complementary.toHexString()}');
  print('text on brand: ${textColor.toHexString()}');
}
