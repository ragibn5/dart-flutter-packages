import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:content_io_android/src/io/reader/channel_content_reader.dart';
import 'package:content_io_android/src/io/reader/content_reader.dart';
import 'package:content_io_android/src/io/reader/descriptor_content_reader.dart';
import 'package:content_io_android/src/io/reader/file_content_reader.dart';
import 'package:content_io_android/src/models/open_read_reply.dart';
import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';
import 'package:content_io_android/src/utils/json_decoder.dart';
import 'package:content_io_android/src/utils/platform_call_guarder.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// Opens a [ContentReader] for the content behind a URI.
abstract interface class ContentReaderFactory {
  /// Opens a reader for the content [request] points to.
  ///
  /// Parameters:
  /// - [request]: the content to open.
  ///
  /// Returns: an open reader; the caller must close it.
  ///
  /// Throws:
  /// - [ContentOpenException] if the content can't be opened.
  Future<ContentReader> open(OpenReadRequest request);

  /// Opens a reader for the thumbnail of the content [request] points to.
  ///
  /// Parameters:
  /// - [request]: the content, and the size to request its thumbnail at.
  ///
  /// Returns: an open reader; the caller must close it.
  ///
  /// Throws:
  /// - [ContentOpenException] if the thumbnail can't be opened.
  ///
  /// Note:
  /// Only the thumbnail's bytes are read, never the original content's.
  Future<ContentReader> openThumbnail(OpenThumbnailReadRequest request);
}

/// The [ContentReaderFactory] that picks the fastest way to read content.
///
/// In order:
/// 1. A [FileContentReader], when [OpenReadRequest.filePath] is given and
///    can be opened.
/// 2. Otherwise, the reader the platform's `openReadSession` reply
///    describes: a [DescriptorContentReader] or a [ChannelContentReader].
final class DefaultContentReaderFactory implements ContentReaderFactory {
  /// The number of local ids handed out, for readers with no platform-side
  /// session.
  static int _localIdCount = 0;

  /// The channel for `openReadSession` and `closeReadSession`.
  final MethodChannel _channel;

  /// The channel for `readFromSession`.
  final MethodChannel _readChannel;

  /// Maps [PlatformException]s to [ContentOpenException]s.
  final ContentOpenExceptionMapper _exceptionMapper;

  const DefaultContentReaderFactory({
    required MethodChannel channel,
    required MethodChannel readChannel,
    ContentOpenExceptionMapper exceptionMapper =
        const ContentOpenExceptionMapper(),
  }) : _channel = channel,
       _readChannel = readChannel,
       _exceptionMapper = exceptionMapper;

  @override
  Future<ContentReader> open(OpenReadRequest request) async {
    final filePath = request.filePath;
    if (filePath != null) {
      try {
        return await FileContentReader.open(id: _nextLocalId(), path: filePath);
      } on FileSystemException catch (e, st) {
        // Not readable by path: falls back to the platform.

        // Log reason.
        log(
          'Exception while opening ${e.path} - falling back to platform.'
          '\nMessage: ${e.message}'
          '\nOsError: ${e.osError}',
          name: 'ContentReaderFactory',
          level: Level.WARNING.value,
          error: e,
          stackTrace: st,
        );
      }
    }

    return _openPlatformReader('openReadSession', jsonEncode(request.toJson()));
  }

  @override
  Future<ContentReader> openThumbnail(OpenThumbnailReadRequest request) {
    // A thumbnail has no file of its own: only the platform can open it.
    return _openPlatformReader(
      'openThumbnailReadSession',
      jsonEncode(request.toJson()),
    );
  }

  /// Opens content through the platform.
  ///
  /// Parameters:
  /// - [method]: the platform method that opens it.
  /// - [arguments]: the encoded request.
  ///
  /// Returns: the reader the platform's reply describes.
  ///
  /// Throws:
  /// - [ContentOpenException] if the platform can't open the content.
  /// - [FormatException] if the reply is malformed.
  Future<ContentReader> _openPlatformReader(
    String method,
    String arguments,
  ) async {
    final result = await guardPlatformCall(
      _exceptionMapper,
      () => _channel.invokeMethod<String>(method, arguments),
    );
    final reply = decodeJsonObject(result!, OpenReadReply.fromJson);

    return switch (reply) {
      DescriptorReply() => DescriptorContentReader(
        id: _nextLocalId(),
        fd: reply.fd,
        offset: reply.offset,
        length: reply.sizeInBytes,
        isSeekable: reply.isSeekable,
      ),
      ChannelReply() => ChannelContentReader(
        id: reply.sessionId,
        channel: _channel,
        readChannel: _readChannel,
        length: reply.sizeInBytes,
        isSeekable: reply.isSeekable,
      ),
    };
  }

  /// Returns a new id for a reader with no platform-side session.
  static String _nextLocalId() => 'local-${++_localIdCount}';
}
