import 'dart:convert';

import 'package:content_io_android/content_io_android_platform_interface.dart';
import 'package:content_io_android/src/exceptions/content_hash_exception_mapper.dart';
import 'package:content_io_android/src/io/reader/content_reader_factory.dart';
import 'package:content_io_android/src/io/session/content_read_session.dart';
import 'package:content_io_android/src/io/session/content_write_session.dart';
import 'package:content_io_android/src/io/writer/content_writer_factory.dart';
import 'package:content_io_android/src/models/content_hash.dart';
import 'package:content_io_android/src/models/hash_content_request.dart';
import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';
import 'package:content_io_android/src/models/open_write_request.dart';
import 'package:content_io_android/src/utils/json_decoder.dart';
import 'package:content_io_android/src/utils/platform_call_guarder.dart';
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

  /// The channel for `hashContent`.
  final MethodChannel _channel;

  /// Maps [PlatformException]s of `hashContent`.
  final ContentHashExceptionMapper _hashExceptionMapper;

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
    @visibleForTesting
    MethodChannel channel = const MethodChannel(CHANNEL_NAME),
    @visibleForTesting
    ContentHashExceptionMapper hashExceptionMapper =
        const ContentHashExceptionMapper(),
  }) : _readerFactory = readerFactory,
       _writerFactory = writerFactory,
       _channel = channel,
       _hashExceptionMapper = hashExceptionMapper;

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

  @override
  Future<ContentHash> hashContent(HashContentRequest request) async {
    final result = await guardPlatformCall(
      _hashExceptionMapper,
      () => _channel.invokeMethod<String>(
        'hashContent',
        jsonEncode(request.toJson()),
      ),
    );
    return decodeJsonObject(result!, ContentHash.fromJson);
  }
}
