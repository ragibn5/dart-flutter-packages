import 'package:content_io_android/content_io_android_platform_interface.dart';
import 'package:content_io_android/src/io/session/content_read_session.dart';
import 'package:content_io_android/src/io/session/content_write_session.dart';
import 'package:content_io_android/src/io/sink/content_byte_sink_factory.dart';
import 'package:content_io_android/src/io/source/content_byte_source_factory.dart';
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

  /// Opens the sources that read sessions read from.
  final ContentByteSourceFactory _sourceFactory;

  /// Opens the sinks that write sessions write to.
  final ContentByteSinkFactory _sinkFactory;

  MethodChannelContentIoAndroid({
    @visibleForTesting
    ContentByteSourceFactory sourceFactory =
        const DefaultContentByteSourceFactory(
          channel: MethodChannel(CHANNEL_NAME),
          readChannel: MethodChannel(READ_CHANNEL_NAME),
        ),
    @visibleForTesting
    ContentByteSinkFactory sinkFactory = const DefaultContentByteSinkFactory(
      channel: MethodChannel(CHANNEL_NAME),
      writeChannel: MethodChannel(WRITE_CHANNEL_NAME),
    ),
  }) : _sourceFactory = sourceFactory,
       _sinkFactory = sinkFactory;

  @override
  Future<ContentReadSession> openReadSession(OpenReadRequest request) async {
    final source = await _sourceFactory.open(request);
    return ContentReadSession(source: source);
  }

  @override
  Future<ContentReadSession> openThumbnailReadSession(
    OpenThumbnailReadRequest request,
  ) async {
    final source = await _sourceFactory.openThumbnail(request);
    return ContentReadSession(source: source);
  }

  @override
  Future<ContentWriteSession> openWriteSession(OpenWriteRequest request) async {
    final sink = await _sinkFactory.open(request);
    return ContentWriteSession(sink: sink);
  }
}
