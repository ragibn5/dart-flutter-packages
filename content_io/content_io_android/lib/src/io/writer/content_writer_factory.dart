import 'dart:convert';

import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:content_io_android/src/io/writer/channel_content_writer.dart';
import 'package:content_io_android/src/io/writer/content_writer.dart';
import 'package:content_io_android/src/io/writer/descriptor_content_writer.dart';
import 'package:content_io_android/src/models/open_write_reply.dart';
import 'package:content_io_android/src/models/open_write_request.dart';
import 'package:content_io_android/src/utils/json_decoder.dart';
import 'package:content_io_android/src/utils/platform_call_guarder.dart';
import 'package:flutter/services.dart';

/// Opens a [ContentWriter] for the content behind a URI.
abstract interface class ContentWriterFactory {
  /// Opens a writer for the content [request] points to.
  ///
  /// Parameters:
  /// - [request]: the content to open, and how.
  ///
  /// Returns: an open writer; the caller must close or abort it.
  ///
  /// Throws:
  /// - [ContentOpenException] if the content can't be opened for writing.
  Future<ContentWriter> open(OpenWriteRequest request);
}

/// The [ContentWriterFactory] that writes the way the platform's
/// `openWriteSession` reply describes: a [DescriptorContentWriter] or a
/// [ChannelContentWriter].
final class DefaultContentWriterFactory implements ContentWriterFactory {
  /// The number of local ids handed out, for writers with no platform-side
  /// session.
  static int _localIdCount = 0;

  /// The channel for `openWriteSession`.
  final MethodChannel _channel;

  /// The channel the platform-side sessions are written over.
  final MethodChannel _writeChannel;

  /// Maps [PlatformException]s to [ContentOpenException]s.
  final ContentOpenExceptionMapper _exceptionMapper;

  const DefaultContentWriterFactory({
    required MethodChannel channel,
    required MethodChannel writeChannel,
    ContentOpenExceptionMapper exceptionMapper =
        const ContentOpenExceptionMapper(),
  }) : _channel = channel,
       _writeChannel = writeChannel,
       _exceptionMapper = exceptionMapper;

  /// Throws:
  /// - [ContentOpenException] if the platform can't open the content.
  /// - [FormatException] if the reply is malformed.
  @override
  Future<ContentWriter> open(OpenWriteRequest request) async {
    final result = await guardPlatformCall(
      _exceptionMapper,
      () => _channel.invokeMethod<String>(
        'openWriteSession',
        jsonEncode(request.toJson()),
      ),
    );
    final reply = decodeJsonObject(result!, OpenWriteReply.fromJson);

    return switch (reply) {
      WriteDescriptorReply() => DescriptorContentWriter(
        id: _nextLocalId(),
        fd: reply.fd,
      ),
      WriteChannelReply() => ChannelContentWriter(
        id: reply.sessionId,
        writeChannel: _writeChannel,
      ),
    };
  }

  /// Returns a new id for a writer with no platform-side session.
  static String _nextLocalId() => 'local-write-${++_localIdCount}';
}
