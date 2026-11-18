import 'package:content_io_android/content_io_android_platform_interface.dart';
import 'package:content_io_android/src/io/reader/content_reader_factory.dart';
import 'package:content_io_android/src/io/session/content_read_session.dart';
import 'package:content_io_android/src/io/session/content_write_session.dart';
import 'package:content_io_android/src/io/writer/content_writer_factory.dart';
import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';
import 'package:content_io_android/src/models/open_write_request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An implementation of [ContentIoAndroidPlatform] that uses method channels.
class MethodChannelContentIoAndroid extends ContentIoAndroidPlatform {
  static const CHANNEL_NAME = 'content_io_android';
  static const READ_CHANNEL_NAME = 'content_io_android/read';
  static const WRITE_CHANNEL_NAME = 'content_io_android/write';

  /// Opens the readers that read sessions read from.
  final ContentReaderFactory _readerFactory;

  /// Opens the writers that write sessions write to.
  final ContentWriterFactory _writerFactory;

  MethodChannelContentIoAndroid({
    @visibleForTesting
    ContentReaderFactory readerFactory = const DefaultContentReaderFactory(
      channel: MethodChannel(CHANNEL_NAME),
      readChannel: MethodChannel(READ_CHANNEL_NAME),
    ),
    @visibleForTesting
    ContentWriterFactory writerFactory = const DefaultContentWriterFactory(
      channel: MethodChannel(CHANNEL_NAME),
      writeChannel: MethodChannel(WRITE_CHANNEL_NAME),
    ),
  }) : _readerFactory = readerFactory,
       _writerFactory = writerFactory;

  @override
  Future<ContentReadSession> openReadSession(OpenReadRequest request) async {
    final reader = await _readerFactory.open(request);
    return ContentReadSession(reader: reader);
  }

  @override
  Future<ContentReadSession> openThumbnailReadSession(
    OpenThumbnailReadRequest request,
  ) async {
    final reader = await _readerFactory.openThumbnail(request);
    return ContentReadSession(reader: reader);
  }

  @override
  Future<ContentWriteSession> openWriteSession(OpenWriteRequest request) async {
    final writer = await _writerFactory.open(request);
    return ContentWriteSession(writer: writer);
  }
}
