import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:content_io_android/src/io/source/channel_byte_source.dart';
import 'package:content_io_android/src/io/source/content_byte_source.dart';
import 'package:content_io_android/src/io/source/descriptor_byte_source.dart';
import 'package:content_io_android/src/io/source/file_byte_source.dart';
import 'package:content_io_android/src/models/open_read_reply.dart';
import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';
import 'package:content_io_android/src/utils/json_decoder.dart';
import 'package:content_io_android/src/utils/platform_call_guarder.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// Opens a [ContentByteSource] for the content behind a URI.
abstract interface class ContentByteSourceFactory {
  /// Opens a source for the content [request] points to.
  ///
  /// Parameters:
  /// - [request]: the content to open.
  ///
  /// Returns: an open source; the caller must close it.
  ///
  /// Throws:
  /// - [ContentOpenException] if the content can't be opened.
  Future<ContentByteSource> open(OpenReadRequest request);

  /// Opens a source for the thumbnail of the content [request] points to.
  ///
  /// Parameters:
  /// - [request]: the content, and the size to request its thumbnail at.
  ///
  /// Returns: an open source; the caller must close it.
  ///
  /// Throws:
  /// - [ContentOpenException] if the thumbnail can't be opened.
  ///
  /// Note:
  /// Only the thumbnail's bytes are read, never the original content's.
  Future<ContentByteSource> openThumbnail(OpenThumbnailReadRequest request);
}

/// The [ContentByteSourceFactory] that picks the fastest way to read content.
///
/// In order:
/// 1. A [FileByteSource], when [OpenReadRequest.filePath] is given and
///    can be opened.
/// 2. Otherwise, the source the platform's `openReadSession` reply
///    describes: a [DescriptorByteSource] or a [ChannelByteSource].
final class DefaultContentByteSourceFactory
    implements ContentByteSourceFactory {
  /// The number of local ids handed out, for sources with no platform-side
  /// session.
  static int _localIdCount = 0;

  /// The channel for `openReadSession` and `closeReadSession`.
  final MethodChannel _channel;

  /// The channel for `readFromSession`.
  final MethodChannel _readChannel;

  /// Maps [PlatformException]s to [ContentOpenException]s.
  final ContentOpenExceptionMapper _exceptionMapper;

  const DefaultContentByteSourceFactory({
    required MethodChannel channel,
    required MethodChannel readChannel,
    ContentOpenExceptionMapper exceptionMapper =
        const ContentOpenExceptionMapper(),
  }) : _channel = channel,
       _readChannel = readChannel,
       _exceptionMapper = exceptionMapper;

  @override
  Future<ContentByteSource> open(OpenReadRequest request) async {
    final filePath = request.filePath;
    if (filePath != null) {
      try {
        return await FileByteSource.open(id: _nextLocalId(), path: filePath);
      } on FileSystemException catch (e, st) {
        // Not readable by path: falls back to the platform.

        // Log reason.
        log(
          'Exception while opening ${e.path} - falling back to platform.'
          '\nMessage: ${e.message}'
          '\nOsError: ${e.osError}',
          name: 'ContentByteSourceFactory',
          level: Level.WARNING.value,
          error: e,
          stackTrace: st,
        );
      }
    }

    return _openPlatformSource('openReadSession', jsonEncode(request.toJson()));
  }

  @override
  Future<ContentByteSource> openThumbnail(OpenThumbnailReadRequest request) {
    // A thumbnail has no file of its own: only the platform can open it.
    return _openPlatformSource(
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
  /// Returns: the source the platform's reply describes.
  ///
  /// Throws:
  /// - [ContentOpenException] if the platform can't open the content.
  /// - [FormatException] if the reply is malformed.
  Future<ContentByteSource> _openPlatformSource(
    String method,
    String arguments,
  ) async {
    final result = await guardPlatformCall(
      _exceptionMapper,
      () => _channel.invokeMethod<String>(method, arguments),
    );
    final reply = decodeJsonObject(result!, OpenReadReply.fromJson);

    return switch (reply) {
      DescriptorReply() => DescriptorByteSource(
        id: _nextLocalId(),
        fd: reply.fd,
        offset: reply.offset,
        length: reply.sizeInBytes,
        isSeekable: reply.isSeekable,
      ),
      ChannelReply() => ChannelByteSource(
        id: reply.sessionId,
        channel: _channel,
        readChannel: _readChannel,
        length: reply.sizeInBytes,
        isSeekable: reply.isSeekable,
      ),
    };
  }

  /// Returns a new id for a source with no platform-side session.
  static String _nextLocalId() => 'local-${++_localIdCount}';
}
