import 'package:content_io_android/src/exceptions/platform_exception_mapper.dart';
import 'package:flutter/services.dart';

/// A failure to write content.
sealed class ContentWriteException implements Exception {
  /// A description of the failure.
  final String? message;

  const ContentWriteException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidWriteRequestError() => '$InvalidWriteRequestError',
    WriteSessionNotFoundException() => '$WriteSessionNotFoundException',
    NotEnoughSpaceException() => '$NotEnoughSpaceException',
    WriteException() => '$WriteException',
  };
}

/// The write request is malformed.
final class InvalidWriteRequestError extends ContentWriteException {
  const InvalidWriteRequestError(super.message);
}

/// The session was not found, or is closed.
final class WriteSessionNotFoundException extends ContentWriteException {
  /// The id of the closed session.
  final String sessionId;

  const WriteSessionNotFoundException(super.message, {required this.sessionId});
}

/// The volume ran out of space while writing the content.
final class NotEnoughSpaceException extends ContentWriteException {
  const NotEnoughSpaceException(super.message);
}

/// An I/O error while writing the content.
final class WriteException extends ContentWriteException {
  const WriteException(super.message);
}

class ContentWriteExceptionMapper implements PlatformExceptionMapper {
  // Must match WriteExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';
  static const _sessionNotFoundCode = 'session_not_found';
  static const _notEnoughSpaceCode = 'not_enough_space';
  static const _writeErrorCode = 'write_error';

  const ContentWriteExceptionMapper();

  @override
  Exception map(PlatformException e) {
    final details = switch (e.details) {
      final Map<Object?, Object?> map => map,
      _ => const <Object?, Object?>{},
    };

    return switch (e.code) {
      _sessionNotFoundCode => WriteSessionNotFoundException(
        e.message,
        sessionId: details['sessionId'] as String? ?? '',
      ),
      _invalidRequestCode => InvalidWriteRequestError(e.message),
      _notEnoughSpaceCode => NotEnoughSpaceException(e.message),
      _writeErrorCode => WriteException(e.message),
      _ => e,
    };
  }
}
