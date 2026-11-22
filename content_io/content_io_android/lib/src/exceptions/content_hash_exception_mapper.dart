import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:content_io_android/src/exceptions/platform_exception_mapper.dart';
import 'package:flutter/services.dart';

/// Maps a failed `hashContent` call: a failure to read the content to a
/// [ContentReadException], any other to a [ContentOpenException].
class ContentHashExceptionMapper implements PlatformExceptionMapper {
  // Must match ReadExceptionCodes.READ_ERROR on the platform side.
  static const _readErrorCode = 'read_error';

  final ContentOpenExceptionMapper _openExceptionMapper;
  final ContentReadExceptionMapper _readExceptionMapper;

  const ContentHashExceptionMapper({
    ContentOpenExceptionMapper openExceptionMapper =
        const ContentOpenExceptionMapper(),
    ContentReadExceptionMapper readExceptionMapper =
        const ContentReadExceptionMapper(),
  }) : _openExceptionMapper = openExceptionMapper,
       _readExceptionMapper = readExceptionMapper;

  @override
  Exception map(PlatformException e) {
    return e.code == _readErrorCode
        ? _readExceptionMapper.map(e)
        : _openExceptionMapper.map(e);
  }
}
