import 'package:flutter/services.dart';

/// A failure to read or write a `MediaStore` item.
sealed class MediaReadException implements Exception {
  /// A description of the failure.
  final String? message;

  const MediaReadException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidRequestException() => '$InvalidRequestException',
    NotFoundException() => '$NotFoundException',
    PermissionDeniedException() => '$PermissionDeniedException',
    UnsupportedOperationException() => '$UnsupportedOperationException',
    SessionClosedException() => '$SessionClosedException',
    ReadingException() => '$ReadingException',
    UnexpectedException() => '$UnexpectedException',
  };
}

/// The request is malformed, or asks for something the target can't do.
final class InvalidRequestException extends MediaReadException {
  const InvalidRequestException(super.message);
}

/// The item doesn't exist, or isn't visible to the app.
final class NotFoundException extends MediaReadException {
  /// The URI of the item that wasn't found.
  final String? uri;

  /// Whether the app only has partial media access
  /// (API level 34+, the user picked specific photos and videos).
  ///
  /// When `true`, the item may exist but not be among the user's selection.
  final bool partialAccess;

  const NotFoundException(
    super.message, {
    required this.uri,
    required this.partialAccess,
  });
}

/// The app lacks permission(s) the operation needs.
final class PermissionDeniedException extends MediaReadException {
  /// The permissions that would satisfy the request.
  final List<String> permissions;

  const PermissionDeniedException(super.message, {required this.permissions});
}

/// The operation isn't supported for this item.
final class UnsupportedOperationException extends MediaReadException {
  const UnsupportedOperationException(super.message);
}

/// The session is closed, or the platform no longer knows it.
final class SessionClosedException extends MediaReadException {
  /// The id of the closed session.
  final String sessionId;

  const SessionClosedException(super.message, {required this.sessionId});
}

/// An I/O error while reading the item.
final class ReadingException extends MediaReadException {
  const ReadingException(super.message);
}

/// A failure the plugin didn't anticipate.
final class UnexpectedException extends MediaReadException {
  /// The error code the platform replied with.
  final String code;

  const UnexpectedException(super.message, {required this.code});
}

class MediaReadErrorMapper {
  static const _permissionDeniedCode = 'permission_denied';
  static const _notFoundCode = 'not_found';
  static const _invalidArgumentCode = 'invalid_argument';
  static const _unsupportedCode = 'unsupported';
  static const _sessionNotFoundCode = 'session_not_found';
  static const _ioErrorCode = 'io_error';

  const MediaReadErrorMapper();

  /// Maps a [PlatformException] to a [MediaReadException].
  MediaReadException map(PlatformException e) {
    final details = switch (e.details) {
      final Map<Object?, Object?> map => map,
      _ => const <Object?, Object?>{},
    };

    return switch (e.code) {
      _permissionDeniedCode => PermissionDeniedException(
        e.message,
        permissions: [
          for (final permission in details['permissions'] as List? ?? const [])
            permission as String,
        ],
      ),
      _notFoundCode => NotFoundException(
        e.message,
        uri: details['uri'] as String?,
        partialAccess: details['partialAccess'] as bool? ?? false,
      ),
      _invalidArgumentCode => InvalidRequestException(e.message),
      _unsupportedCode => UnsupportedOperationException(e.message),
      _sessionNotFoundCode => SessionClosedException(
        e.message,
        sessionId: details['sessionId'] as String? ?? '',
      ),
      _ioErrorCode => ReadingException(e.message),
      _ => UnexpectedException(e.message, code: e.code),
    };
  }
}
