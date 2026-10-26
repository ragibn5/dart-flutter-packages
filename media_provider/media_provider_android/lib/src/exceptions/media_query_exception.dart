import 'package:flutter/services.dart';
import 'package:media_provider_android/src/exceptions/platform_exception_mapper.dart';

/// A failure to query `MediaStore` collection.
sealed class MediaQueryException implements Exception {
  /// A description of the failure.
  final String? message;

  const MediaQueryException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidQueryError() => '$InvalidQueryError',
  };
}

/// The query is malformed, or asks for something the target can't do.
final class InvalidQueryError extends MediaQueryException {
  const InvalidQueryError(super.message);
}

class MediaQueryExceptionMapper implements PlatformExceptionMapper {
  static const _invalidRequestCode = 'invalid_request';

  const MediaQueryExceptionMapper();

  @override
  Exception map(PlatformException e) {
    return switch (e.code) {
      _invalidRequestCode => InvalidQueryError(e.message),
      _ => e,
    };
  }
}
