import 'package:flutter/services.dart';
import 'package:media_provider_android/src/exceptions/platform_exception_mapper.dart';

/// A failure to hand `MediaStore` items to another app.
sealed class MediaActionException implements Exception {
  /// A description of the failure.
  final String? message;

  const MediaActionException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidActionRequestError() => '$InvalidActionRequestError',
    ActionNotPermittedException() => '$ActionNotPermittedException',
    NoActivityException() => '$NoActivityException',
  };
}

/// The request is malformed, or points to something that isn't a media item.
final class InvalidActionRequestError extends MediaActionException {
  const InvalidActionRequestError(super.message);
}

/// The app may not give another app access to the items.
final class ActionNotPermittedException extends MediaActionException {
  const ActionNotPermittedException(super.message);
}

/// No activity is attached to show the chooser from, such as while the app is
/// in the background.
final class NoActivityException extends MediaActionException {
  const NoActivityException(super.message);
}

class MediaActionExceptionMapper implements PlatformExceptionMapper {
  // Must match MediaActionExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';
  static const _permissionDeniedCode = 'permission_denied';
  static const _noActivityCode = 'no_activity';

  const MediaActionExceptionMapper();

  /// Maps a [PlatformException] to a [MediaActionException].
  @override
  Exception map(PlatformException e) {
    return switch (e.code) {
      _invalidRequestCode => InvalidActionRequestError(e.message),
      _permissionDeniedCode => ActionNotPermittedException(e.message),
      _noActivityCode => NoActivityException(e.message),
      _ => e,
    };
  }
}
