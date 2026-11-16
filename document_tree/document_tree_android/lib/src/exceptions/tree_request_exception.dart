import 'package:document_tree_android/src/exceptions/platform_exception_mapper.dart';
import 'package:flutter/services.dart';

/// A failure to get or release a document tree.
sealed class TreeRequestException implements Exception {
  /// A description of the failure.
  final String? message;

  const TreeRequestException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidTreeRequestError() => '$InvalidTreeRequestError',
  };
}

/// The URI is blank, or isn't a document tree's.
final class InvalidTreeRequestError extends TreeRequestException {
  const InvalidTreeRequestError(super.message);
}

class TreeRequestExceptionMapper implements PlatformExceptionMapper {
  // Must match TreeRequestExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';

  const TreeRequestExceptionMapper();

  @override
  Exception map(PlatformException e) {
    return switch (e.code) {
      _invalidRequestCode => InvalidTreeRequestError(e.message),
      _ => e,
    };
  }
}
