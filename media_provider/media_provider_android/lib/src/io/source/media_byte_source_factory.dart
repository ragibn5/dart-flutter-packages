import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_provider_android/src/exceptions/media_read_open_exception.dart';
import 'package:media_provider_android/src/io/source/channel_byte_source.dart';
import 'package:media_provider_android/src/io/source/descriptor_byte_source.dart';
import 'package:media_provider_android/src/io/source/file_byte_source.dart';
import 'package:media_provider_android/src/io/source/media_byte_source.dart';
import 'package:media_provider_android/src/models/open_media_read_reply.dart';
import 'package:media_provider_android/src/models/open_media_read_request.dart';
import 'package:media_provider_android/src/models/open_thumbnail_read_request.dart';
import 'package:media_provider_android/src/utils/json_decoding.dart';
import 'package:media_provider_android/src/utils/platform_exception_mapper.dart';

/// Opens a [MediaByteSource] for a media item.
abstract interface class MediaByteSourceFactory {
  /// Opens a source for the item [request] points to.
  ///
  /// Parameters:
  /// - [request]: the item to open.
  ///
  /// Returns: an open source; the caller must close it.
  ///
  /// Throws:
  /// - [MediaReadOpenException] if the item can't be opened.
  Future<MediaByteSource> open(OpenMediaReadRequest request);

  /// Opens a source for the thumbnail of the item [request] points to.
  ///
  /// Parameters:
  /// - [request]: the item, and the size to request its thumbnail at.
  ///
  /// Returns: an open source; the caller must close it.
  ///
  /// Throws:
  /// - [MediaReadOpenException] if the thumbnail can't be opened.
  ///
  /// Note:
  /// Only the thumbnail's bytes are read, never the original item's.
  Future<MediaByteSource> openThumbnail(OpenThumbnailReadRequest request);
}

/// The [MediaByteSourceFactory] that picks the fastest way to read an item.
///
/// In order:
/// 1. A [FileByteSource], when [OpenMediaReadRequest.filePath] is given and
///    can be opened.
/// 2. Otherwise, the source the platform's `openMediaReadSession` reply
///    describes: a [DescriptorByteSource] or a [ChannelByteSource].
final class DefaultMediaByteSourceFactory implements MediaByteSourceFactory {
  /// The number of local ids handed out, for sources with no platform-side
  /// session.
  static int _localIdCount = 0;

  /// The channel for `openMediaReadSession` and `closeReadSession`.
  final MethodChannel _channel;

  /// The channel for `readFromSession`.
  final MethodChannel _readChannel;

  /// Maps [PlatformException]s to [MediaReadOpenException]s.
  final MediaReadOpenErrorMapper _exceptionMapper;

  const DefaultMediaByteSourceFactory({
    required MethodChannel channel,
    required MethodChannel readChannel,
    MediaReadOpenErrorMapper exceptionMapper = const MediaReadOpenErrorMapper(),
  }) : _channel = channel,
       _readChannel = readChannel,
       _exceptionMapper = exceptionMapper;

  @override
  Future<MediaByteSource> open(OpenMediaReadRequest request) async {
    final filePath = request.filePath;
    if (filePath != null) {
      try {
        return await FileByteSource.open(id: _nextLocalId(), path: filePath);
      } on FileSystemException catch (e, st) {
        // Not readable by path: falls back to the platform.

        // Log reason.
        debugPrintStack(
          label:
              'Exception while opening ${e.path} - falling back to platform.'
              '\nMessage: ${e.message}'
              '\nOsError: ${e.osError}',
          stackTrace: st,
        );
      }
    }

    return _openPlatformSource(
      'openMediaReadSession',
      jsonEncode(request.toJson()),
    );
  }

  @override
  Future<MediaByteSource> openThumbnail(OpenThumbnailReadRequest request) {
    // A thumbnail has no file of its own: only the platform can open it.
    return _openPlatformSource(
      'openThumbnailReadSession',
      jsonEncode(request.toJson()),
    );
  }

  /// Opens an item through the platform.
  ///
  /// Parameters:
  /// - [method]: the platform method that opens it.
  /// - [arguments]: the encoded request.
  ///
  /// Returns: the source the platform's reply describes.
  ///
  /// Throws:
  /// - [MediaReadOpenException] if the platform can't open the item.
  /// - [FormatException] if the reply is malformed.
  Future<MediaByteSource> _openPlatformSource(
    String method,
    String arguments,
  ) async {
    final result = await guardPlatformCall(
      () => _channel.invokeMethod<String>(method, arguments),
      _exceptionMapper.map,
    );
    final reply = decodeJsonObject(result!, OpenMediaReadReply.fromJson);

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
