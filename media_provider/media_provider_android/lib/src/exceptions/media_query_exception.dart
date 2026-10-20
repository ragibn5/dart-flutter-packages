import 'package:flutter/services.dart';

/// A failure to query `MediaStore` collection.
sealed class MediaQueryException implements Exception {
  /// A description of the failure.
  final String? message;

  const MediaQueryException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidRequestError() => '$InvalidRequestError',
  };
}

/// The request is malformed, or asks for something the target can't do.
final class InvalidRequestError extends MediaQueryException {
  const InvalidRequestError(super.message);
}

class MediaQueryExceptionMapper {
  static const _invalidRequestCode = 'invalid_request';

  const MediaQueryExceptionMapper();

  /// Maps a [PlatformException] to a [MediaQueryException].
  Exception map(PlatformException e) {
    return switch (e.code) {
      _invalidRequestCode => InvalidRequestError(e.message),
      _ => e,
    };
  }
}
