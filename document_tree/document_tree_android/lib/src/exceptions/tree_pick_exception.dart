import 'package:document_tree_android/src/exceptions/platform_exception_mapper.dart';
import 'package:flutter/services.dart';

/// A failure to let the user pick a document tree.
sealed class TreePickException implements Exception {
  /// A description of the failure.
  final String? message;

  const TreePickException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidPickRequestError() => '$InvalidPickRequestError',
    NoActivityException() => '$NoActivityException',
    PickerAlreadyOpenException() => '$PickerAlreadyOpenException',
    PickerUnavailableException() => '$PickerUnavailableException',
  };
}

/// The request is malformed.
final class InvalidPickRequestError extends TreePickException {
  const InvalidPickRequestError(super.message);
}

/// No activity is attached to show the picker from, such as while the app is
/// in the background.
final class NoActivityException extends TreePickException {
  const NoActivityException(super.message);
}

/// The picker is already open; only one can be open at a time.
final class PickerAlreadyOpenException extends TreePickException {
  const PickerAlreadyOpenException(super.message);
}

/// The device has no folder picker, as on some Android Go and TV builds.
final class PickerUnavailableException extends TreePickException {
  const PickerUnavailableException(super.message);
}

class TreePickExceptionMapper implements PlatformExceptionMapper {
  // Must match TreePickExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';
  static const _noActivityCode = 'no_activity';
  static const _pickerAlreadyOpenCode = 'picker_already_open';
  static const _pickerUnavailableCode = 'picker_unavailable';

  const TreePickExceptionMapper();

  @override
  Exception map(PlatformException e) {
    return switch (e.code) {
      _invalidRequestCode => InvalidPickRequestError(e.message),
      _noActivityCode => NoActivityException(e.message),
      _pickerAlreadyOpenCode => PickerAlreadyOpenException(e.message),
      _pickerUnavailableCode => PickerUnavailableException(e.message),
      _ => e,
    };
  }
}
