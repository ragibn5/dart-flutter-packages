import 'package:document_tree_android/src/exceptions/platform_exception_mapper.dart';
import 'package:flutter/services.dart';

/// A failure to list the documents in a tree.
sealed class DocumentQueryException implements Exception {
  /// A description of the failure.
  final String? message;

  const DocumentQueryException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    InvalidQueryError() => '$InvalidQueryError',
    TreeAccessLostException() => '$TreeAccessLostException',
    TreeUnavailableException() => '$TreeUnavailableException',
    DocumentNotFoundException() => '$DocumentNotFoundException',
  };
}

/// The request is malformed: its URI isn't a tree's, or its path has empty,
/// `.` or `..` segments.
final class InvalidQueryError extends DocumentQueryException {
  const InvalidQueryError(super.message);
}

/// The app holds no grant on the tree, or it was revoked.
final class TreeAccessLostException extends DocumentQueryException {
  const TreeAccessLostException(super.message);
}

/// The tree can't be read, such as when it was deleted or its volume was
/// removed.
final class TreeUnavailableException extends DocumentQueryException {
  const TreeUnavailableException(super.message);
}

/// No folder is at the requested path.
final class DocumentNotFoundException extends DocumentQueryException {
  const DocumentNotFoundException(super.message);
}

class DocumentQueryExceptionMapper implements PlatformExceptionMapper {
  // Must match DocumentQueryExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';
  static const _accessLostCode = 'access_lost';
  static const _treeUnavailableCode = 'tree_unavailable';
  static const _notFoundCode = 'not_found';

  const DocumentQueryExceptionMapper();

  @override
  Exception map(PlatformException e) {
    return switch (e.code) {
      _invalidRequestCode => InvalidQueryError(e.message),
      _accessLostCode => TreeAccessLostException(e.message),
      _treeUnavailableCode => TreeUnavailableException(e.message),
      _notFoundCode => DocumentNotFoundException(e.message),
      _ => e,
    };
  }
}
