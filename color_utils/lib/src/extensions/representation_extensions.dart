import 'dart:ui';

extension RepresentationExtension on Color {
  /// Provides the hex representation of this color.
  String toHexString() {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
