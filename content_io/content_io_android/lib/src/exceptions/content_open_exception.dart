import 'package:content_io_android/src/exceptions/platform_exception_mapper.dart';
import 'package:flutter/services.dart';

/// A failure to open content for reading.
sealed class ContentOpenException implements Exception {
  /// A description of the failure.
  final String? message;

  const ContentOpenException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidOpenRequestError() => '$InvalidOpenRequestError',
    ContentNotFoundException() => '$ContentNotFoundException',
    PermissionDeniedException() => '$PermissionDeniedException',
    UnsupportedOperationException() => '$UnsupportedOperationException',
  };
}

/// The open request is malformed, or asks for something the target can't do.
final class InvalidOpenRequestError extends ContentOpenException {
  const InvalidOpenRequestError(super.message);
}

/// The content doesn't exist, or isn't visible to the app.
final class ContentNotFoundException extends ContentOpenException {
  /// The URI of the content that wasn't found.
  final String? uri;

  const ContentNotFoundException(super.message, {required this.uri});
}

/// The app lacks permission to perform the operation.
final class PermissionDeniedException extends ContentOpenException {
  const PermissionDeniedException(super.message);
}

/// The operation isn't supported for this content.
final class UnsupportedOperationException extends ContentOpenException {
  const UnsupportedOperationException(super.message);
}

class ContentOpenExceptionMapper implements PlatformExceptionMapper {
  // Must match OpenReadExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';
  static const _notFoundCode = 'not_found';
  static const _permissionDeniedCode = 'permission_denied';
  static const _unsupportedCode = 'unsupported_operation';

  const ContentOpenExceptionMapper();

  @override
  Exception map(PlatformException e) {
    final details = switch (e.details) {
      final Map<Object?, Object?> map => map,
      _ => const <Object?, Object?>{},
    };

    return switch (e.code) {
      _permissionDeniedCode => PermissionDeniedException(e.message),
      _notFoundCode => ContentNotFoundException(
        e.message,
        uri: details['uri'] as String?,
      ),
      _invalidRequestCode => InvalidOpenRequestError(e.message),
      _unsupportedCode => UnsupportedOperationException(e.message),
      _ => e,
    };
  }
}
