import 'package:document_tree_android/src/exceptions/platform_exception_mapper.dart';
import 'package:flutter/services.dart';

/// A failure to list the documents in a tree.
sealed class DocumentQueryException implements Exception {
  /// A description of the failure.
  String? get message;
}

/// A failure to write a document into a tree.
sealed class DocumentWriteException implements Exception {
  /// A description of the failure.
  String? get message;
}

/// The base of every document failure.
///
/// Note:
/// One library holds them all, so a failure every operation shares, such as
/// [TreeAccessLostException], can be both a [DocumentQueryException] and a
/// [DocumentWriteException].
sealed class _DocumentException implements Exception {
  final String? message;

  const _DocumentException(this.message);

  @override
  String toString() => '$_typeName: ${message ?? 'no message'}';

  String get _typeName => switch (this) {
    TreeAccessLostException() => '$TreeAccessLostException',
    TreeUnavailableException() => '$TreeUnavailableException',
    InvalidQueryError() => '$InvalidQueryError',
    DocumentNotFoundException() => '$DocumentNotFoundException',
    InvalidWriteError() => '$InvalidWriteError',
    TreeNotWritableException() => '$TreeNotWritableException',
    DocumentAlreadyExistsException() => '$DocumentAlreadyExistsException',
    SourceNotFoundException() => '$SourceNotFoundException',
    SourcePermissionDeniedException() => '$SourcePermissionDeniedException',
    NotEnoughSpaceException() => '$NotEnoughSpaceException',
    DocumentWriteFailedException() => '$DocumentWriteFailedException',
  };
}

/// The app holds no grant on the tree, or it was revoked.
final class TreeAccessLostException extends _DocumentException
    implements DocumentQueryException, DocumentWriteException {
  const TreeAccessLostException(super.message);
}

/// The tree can't be reached, such as when it was deleted or its volume was
/// removed.
final class TreeUnavailableException extends _DocumentException
    implements DocumentQueryException, DocumentWriteException {
  const TreeUnavailableException(super.message);
}

/// The request is malformed: its URI isn't a tree's, or its path has empty,
/// `.` or `..` segments.
final class InvalidQueryError extends _DocumentException
    implements DocumentQueryException {
  const InvalidQueryError(super.message);
}

/// No folder is at the requested path.
final class DocumentNotFoundException extends _DocumentException
    implements DocumentQueryException {
  const DocumentNotFoundException(super.message);
}

/// The request is malformed: the source URI has no scheme, the tree URI isn't
/// a tree's, the path doesn't name a file or has empty, `.` or `..` segments,
/// or the MIME type is blank.
final class InvalidWriteError extends _DocumentException
    implements DocumentWriteException {
  const InvalidWriteError(super.message);
}

/// The app's grant on the tree doesn't allow writing.
final class TreeNotWritableException extends _DocumentException
    implements DocumentWriteException {
  const TreeNotWritableException(super.message);
}

/// A document is already where the write would go: a file, when overwriting
/// wasn't asked for, a folder, or one whose name differs only in case. Also
/// when a file is where a folder on the path should be.
final class DocumentAlreadyExistsException extends _DocumentException
    implements DocumentWriteException {
  const DocumentAlreadyExistsException(super.message);
}

/// The source can't be opened, such as when it was deleted.
final class SourceNotFoundException extends _DocumentException
    implements DocumentWriteException {
  const SourceNotFoundException(super.message);
}

/// The app isn't allowed to read the source.
final class SourcePermissionDeniedException extends _DocumentException
    implements DocumentWriteException {
  const SourcePermissionDeniedException(super.message);
}

/// The tree's volume ran out of space.
final class NotEnoughSpaceException extends _DocumentException
    implements DocumentWriteException {
  const NotEnoughSpaceException(super.message);
}

/// The write failed for another reason, such as an I/O error, or the provider
/// refusing to create the document or naming it differently.
final class DocumentWriteFailedException extends _DocumentException
    implements DocumentWriteException {
  const DocumentWriteFailedException(super.message);
}

// Must match DocumentAccessExceptionCodes on the platform side.
const _accessLostCode = 'access_lost';
const _treeUnavailableCode = 'tree_unavailable';

class DocumentQueryExceptionMapper implements PlatformExceptionMapper {
  // Must match DocumentQueryExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';
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

class DocumentWriteExceptionMapper implements PlatformExceptionMapper {
  // Must match DocumentWriteExceptionCodes on the platform side.
  static const _invalidRequestCode = 'invalid_request';
  static const _notWritableCode = 'not_writable';
  static const _alreadyExistsCode = 'already_exists';
  static const _sourceNotFoundCode = 'source_not_found';
  static const _sourcePermissionDeniedCode = 'source_permission_denied';
  static const _notEnoughSpaceCode = 'not_enough_space';
  static const _writeErrorCode = 'write_error';

  const DocumentWriteExceptionMapper();

  @override
  Exception map(PlatformException e) {
    return switch (e.code) {
      _invalidRequestCode => InvalidWriteError(e.message),
      _accessLostCode => TreeAccessLostException(e.message),
      _treeUnavailableCode => TreeUnavailableException(e.message),
      _notWritableCode => TreeNotWritableException(e.message),
      _alreadyExistsCode => DocumentAlreadyExistsException(e.message),
      _sourceNotFoundCode => SourceNotFoundException(e.message),
      _sourcePermissionDeniedCode => SourcePermissionDeniedException(e.message),
      _notEnoughSpaceCode => NotEnoughSpaceException(e.message),
      _writeErrorCode => DocumentWriteFailedException(e.message),
      _ => e,
    };
  }
}
