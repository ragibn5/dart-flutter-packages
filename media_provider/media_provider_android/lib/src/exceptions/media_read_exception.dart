import 'package:flutter/services.dart';

/// A failure to read a `MediaStore` item.
sealed class MediaReadException implements Exception {
  /// A description of the failure.
  final String? message;

  const MediaReadException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    SessionNotFoundException() => '$SessionNotFoundException',
    ReadException() => '$ReadException',
  };
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

class MediaReadExceptionMapper {
  static const _sessionNotFoundCode = 'session_not_found';
  static const _ioErrorCode = 'io_error';

  const MediaReadExceptionMapper();

  /// Maps a [PlatformException] to a [MediaReadException].
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
      _ioErrorCode => ReadException(e.message),
      _ => e,
    };
  }
}
