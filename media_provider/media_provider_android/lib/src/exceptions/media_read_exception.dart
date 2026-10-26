import 'package:flutter/services.dart';
import 'package:media_provider_android/src/exceptions/platform_exception_mapper.dart';

/// A failure to read a `MediaStore` item.
sealed class MediaReadException implements Exception {
  /// A description of the failure.
  final String? message;

  const MediaReadException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidReadRequestError() => '$InvalidReadRequestError',
    SessionNotFoundException() => '$SessionNotFoundException',
    ReadException() => '$ReadException',
  };
}

/// The read request is malformed.
final class InvalidReadRequestError extends MediaReadException {
  const InvalidReadRequestError(super.message);
}

/// The session was not found, or is closed.
final class SessionNotFoundException extends MediaReadException {
  /// The id of the closed session.
  final String sessionId;

  const SessionNotFoundException(super.message, {required this.sessionId});
}

/// An I/O error while reading the item.
final class ReadException extends MediaReadException {
  const ReadException(super.message);
}

class MediaReadExceptionMapper implements PlatformExceptionMapper {
  // Must match MediaReadExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';
  static const _sessionNotFoundCode = 'session_not_found';
  static const _readErrorCode = 'read_error';

  const MediaReadExceptionMapper();

  @override
  Exception map(PlatformException e) {
    final details = switch (e.details) {
      final Map<Object?, Object?> map => map,
      _ => const <Object?, Object?>{},
    };

    return switch (e.code) {
      _sessionNotFoundCode => SessionNotFoundException(
        e.message,
        sessionId: details['sessionId'] as String? ?? '',
      ),
      _invalidRequestCode => InvalidReadRequestError(e.message),
      _readErrorCode => ReadException(e.message),
      _ => e,
    };
  }
}
