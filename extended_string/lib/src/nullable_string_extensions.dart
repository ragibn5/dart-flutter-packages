import 'package:extended_string/src/non_nullable_string_extensions.dart';

extension NullableStringExtension on String? {
  /// Determines if this string is null, empty, or contains only whitespace.
  ///
  /// Example:
  /// ```dart
  /// null.isNullOrEmptyOrBlank; // true
  /// ''.isNullOrEmptyOrBlank; // true
  /// '   '.isNullOrEmptyOrBlank; // true
  /// 'Hello'.isNullOrEmptyOrBlank; // false
  /// ```
  bool get isNullOrEmptyOrBlank {
    return this == null || this!.isEmptyOrBlank;
  }

  /// Converts empty or blank strings to null.
  ///
  /// Example:
  /// ```dart
  /// null.nullOnEmptyOrBlank; // null
  /// ''.nullOnEmptyOrBlank; // null
  /// '   '.nullOnEmptyOrBlank; // null
  /// 'Hello'.nullOnEmptyOrBlank; // 'Hello'
  /// ```
  ///
  /// Useful for form validation and data normalization.
  String? get nullOnEmptyOrBlank {
    return isNullOrEmptyOrBlank ? null : this!;
  }
}
