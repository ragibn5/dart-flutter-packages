import 'package:flutter/services.dart';
import 'package:media_provider_android/src/exceptions/platform_exception_mapper.dart';

/// A failure to open a `MediaStore` item for reading.
sealed class MediaReadOpenException implements Exception {
  /// A description of the failure.
  final String? message;

  const MediaReadOpenException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidOpenRequestError() => '$InvalidOpenRequestError',
    MediaNotFoundException() => '$MediaNotFoundException',
    PermissionDeniedException() => '$PermissionDeniedException',
    UnsupportedOperationException() => '$UnsupportedOperationException',
  };
}

/// The open request is malformed, or asks for something the target can't do.
final class InvalidOpenRequestError extends MediaReadOpenException {
  const InvalidOpenRequestError(super.message);
}

/// The item doesn't exist, or isn't visible to the app.
final class MediaNotFoundException extends MediaReadOpenException {
  /// The URI of the item that wasn't found.
  final String? uri;

  /// Whether the app only has partial media access
  /// (API level 34+, the user picked specific photos and videos).
  ///
  /// When `true`, the item may exist but not be among the user's selection.
  final bool partialAccess;

  const MediaNotFoundException(
    super.message, {
    required this.uri,
    required this.partialAccess,
  });
}

/// The app lacks permission to perform the operation.
final class PermissionDeniedException extends MediaReadOpenException {
  const PermissionDeniedException(super.message);
}

/// The operation isn't supported for this item.
final class UnsupportedOperationException extends MediaReadOpenException {
  const UnsupportedOperationException(super.message);
}

class MediaReadOpenExceptionMapper implements PlatformExceptionMapper {
  // Must match OpenMediaReadExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';
  static const _notFoundCode = 'not_found';
  static const _permissionDeniedCode = 'permission_denied';
  static const _unsupportedCode = 'unsupported_operation';

  const MediaReadOpenExceptionMapper();

  /// Maps a [PlatformException] to a [MediaReadOpenException].
  @override
  Exception map(PlatformException e) {
    final details = switch (e.details) {
      final Map<Object?, Object?> map => map,
      _ => const <Object?, Object?>{},
    };

    return switch (e.code) {
      _permissionDeniedCode => PermissionDeniedException(e.message),
      _notFoundCode => MediaNotFoundException(
        e.message,
        uri: details['uri'] as String?,
        partialAccess: details['partialAccess'] as bool? ?? false,
      ),
      _invalidRequestCode => InvalidOpenRequestError(e.message),
      _unsupportedCode => UnsupportedOperationException(e.message),
      _ => e,
    };
  }
}
