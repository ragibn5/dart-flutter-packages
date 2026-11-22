/// Reads and writes the bytes behind Android `content://` URIs, such as
/// photos, videos and documents, reads their thumbnails, and hashes them.
library;

import 'package:content_io_android/content_io_android_platform_interface.dart';
import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:content_io_android/src/io/session/content_read_session.dart';
import 'package:content_io_android/src/io/session/content_write_session.dart';
import 'package:content_io_android/src/models/content_hash.dart';
import 'package:content_io_android/src/models/hash_content_request.dart';
import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';
import 'package:content_io_android/src/models/open_write_request.dart';

export 'src/exceptions/content_open_exception.dart'
    hide ContentOpenExceptionMapper;
export 'src/exceptions/content_read_exception.dart'
    hide ContentReadExceptionMapper;
export 'src/exceptions/content_write_exception.dart'
    hide ContentWriteExceptionMapper;
export 'src/io/session/content_read_session.dart';
export 'src/io/session/content_write_session.dart';
export 'src/models/content_hash.dart';
export 'src/models/content_hash_algorithm.dart';
export 'src/models/hash_content_request.dart';
export 'src/models/open_read_request.dart';
export 'src/models/open_thumbnail_read_request.dart';
export 'src/models/open_write_request.dart';
export 'src/models/thumbnail_size.dart';
export 'src/models/write_mode.dart';

class ContentIoAndroid {
  /// Opens a session for reading the content [request] points to.
  ///
  /// See [ContentReadSession] for more info.
  Future<ContentReadSession> openReadSession(OpenReadRequest request) {
    return ContentIoAndroidPlatform.instance.openReadSession(request);
  }

  /// Opens a session for reading the thumbnail of the content [request]
  /// points to.
  ///
  /// Only the thumbnail's bytes are read, never the original content's. See
  /// [ContentReadSession] for more info.
  Future<ContentReadSession> openThumbnailReadSession(
    OpenThumbnailReadRequest request,
  ) {
    return ContentIoAndroidPlatform.instance.openThumbnailReadSession(request);
  }

  /// Opens a session for writing the content [request] points to.
  ///
  /// See [ContentWriteSession] and [OpenWriteRequest] for more info.
  Future<ContentWriteSession> openWriteSession(OpenWriteRequest request) {
    return ContentIoAndroidPlatform.instance.openWriteSession(request);
  }

  /// Hashes the whole content [request] points to, on the platform side.
  ///
  /// The content's bytes never cross to Dart, so this is much faster than
  /// hashing a [ContentReadSession]'s bytes.
  ///
  /// Throws:
  /// - [ContentOpenException] if the content can't be opened.
  /// - [ContentReadException] if it can't be read to its end.
  Future<ContentHash> hashContent(HashContentRequest request) {
    return ContentIoAndroidPlatform.instance.hashContent(request);
  }
}
