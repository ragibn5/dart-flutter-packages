import 'package:content_io_android/src/exceptions/platform_exception_mapper.dart';
import 'package:flutter/services.dart';

/// A failure to read content.
sealed class ContentReadException implements Exception {
  /// A description of the failure.
  final String? message;

  const ContentReadException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidReadRequestError() => '$InvalidReadRequestError',
    SessionNotFoundException() => '$SessionNotFoundException',
    ReadException() => '$ReadException',
  };
}

/// The read request is malformed.
final class InvalidReadRequestError extends ContentReadException {
  const InvalidReadRequestError(super.message);
}

/// The session was not found, or is closed.
final class SessionNotFoundException extends ContentReadException {
  /// The id of the closed session.
  final String sessionId;

  const SessionNotFoundException(super.message, {required this.sessionId});
}

/// An I/O error while reading the content.
final class ReadException extends ContentReadException {
  const ReadException(super.message);
}

class ContentReadExceptionMapper implements PlatformExceptionMapper {
  // Must match ReadExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';
  static const _sessionNotFoundCode = 'session_not_found';
  static const _readErrorCode = 'read_error';

  const ContentReadExceptionMapper();

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
