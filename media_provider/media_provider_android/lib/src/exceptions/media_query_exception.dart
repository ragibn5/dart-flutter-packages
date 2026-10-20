import 'package:flutter/services.dart';

/// A failure to query `MediaStore` collection.
sealed class MediaQueryException implements Exception {
  /// A description of the failure.
  final String? message;

  const MediaQueryException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidRequestException() => '$InvalidRequestException',
    UnexpectedException() => '$UnexpectedException',
  };
}

/// The request is malformed, or asks for something the target can't do.
final class InvalidRequestException extends MediaQueryException {
  const InvalidRequestException(super.message);
}

/// A failure the plugin didn't anticipate.
final class UnexpectedException extends MediaQueryException {
  /// The error code the platform replied with.
  final String? code;

  const UnexpectedException(super.message, {this.code});
}

class MediaQueryErrorMapper {
  static const _invalidRequestCode = 'invalid_request';

  const MediaQueryErrorMapper();

  /// Maps a [PlatformException] to a [MediaQueryException].
  MediaQueryException map(PlatformException e) {
    return switch (e.code) {
      _invalidRequestCode => InvalidRequestException(e.message),
      _ => UnexpectedException(e.message, code: e.code),
    };
  }
}
