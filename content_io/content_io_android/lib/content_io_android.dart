/// Reads the bytes behind Android `content://` URIs, such as photos, videos
/// and documents, with their thumbnails.
library;

import 'package:content_io_android/content_io_android_platform_interface.dart';
import 'package:content_io_android/src/io/session/content_read_session.dart';
import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';

export 'src/exceptions/content_open_exception.dart'
    hide ContentOpenExceptionMapper;
export 'src/exceptions/content_read_exception.dart'
    hide ContentReadExceptionMapper;
export 'src/io/session/content_read_session.dart';
export 'src/models/open_read_request.dart';
export 'src/models/open_thumbnail_read_request.dart';
export 'src/models/thumbnail_size.dart';

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
}
