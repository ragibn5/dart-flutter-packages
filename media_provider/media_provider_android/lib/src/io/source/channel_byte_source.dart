import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:media_provider_android/src/exceptions/media_read_exception.dart';
import 'package:media_provider_android/src/io/source/media_byte_source.dart';
import 'package:media_provider_android/src/models/media_read_request.dart';
import 'package:media_provider_android/src/utils/platform_exception_mapper.dart';
import 'package:meta/meta.dart';

/// A [MediaByteSource] for a platform-side read session, read over the
/// method channel.
///
/// Each read takes one or more `readFromSession` calls, of at most
/// [_maxBytesPerCall] bytes each.
final class ChannelByteSource extends MediaByteSource {
  /// The maximum number of bytes requested per `readFromSession` call.
  static const _maxBytesPerCall = 512 * 1024;

  /// The current position, sent as the `start` of each read.
  int _position = 0;

  /// The channel for `closeReadSession`.
  final MethodChannel _channel;

  /// The channel for `readFromSession`, handled off the platform's main
  /// thread.
  final MethodChannel _readChannel;

  /// Maps [PlatformException]s to [MediaReadException]s.
  final MediaReadExceptionMapper _exceptionMapper;

  /// The id of the platform-side session.
  @override
  final String id;

  @override
  final int? length;

  @override
  final bool isSeekable;

  ChannelByteSource({
    required MethodChannel readChannel,
    required MethodChannel channel,
    required this.id,
    required this.length,
    required this.isSeekable,
    @visibleForTesting
    MediaReadExceptionMapper exceptionMapper = const MediaReadExceptionMapper(),
  }) : _readChannel = readChannel,
       _channel = channel,
       _exceptionMapper = exceptionMapper;

  @override
  Future<Uint8List> read(int maxLength, {int? position}) async {
    if (position != null) {
      _seek(position);
    }
    final builder = BytesBuilder(copy: false);
    while (builder.length < maxLength) {
      final piece = await _readPiece(
        min(maxLength - builder.length, _maxBytesPerCall),
      );
      if (piece.isEmpty) {
        break;
      }
      builder.add(piece);
    }
    return builder.takeBytes();
  }

  @override
  Future<Uint8List> readAll({int? position}) async {
    if (position != null) {
      _seek(position);
    }
    return readToEnd(_maxBytesPerCall);
  }

  @override
  Future<void> close() async {
    try {
      await _channel.invokeMethod<void>('closeReadSession', {'sessionId': id});
    } catch (_) {
      // Ignored: [close] never throws.
    }
  }

  /// Moves the current position to [position].
  ///
  /// Throws:
  /// - [RangeError] if [position] is negative.
  /// - [UnsupportedError] if the session isn't [isSeekable].
  void _seek(int position) {
    RangeError.checkNotNegative(position, 'position');
    if (!isSeekable) {
      throw UnsupportedError('Session $id is not seekable');
    }
    _position = position;
  }

  /// Reads from the current position with one `readFromSession` call, and
  /// advances the position by the bytes read.
  ///
  /// Parameters:
  /// - [length]: the maximum number of bytes to read.
  ///
  /// Returns: the bytes read; empty at the end of the item.
  ///
  /// Throws:
  /// - [MediaReadException] if the platform fails to read.
  Future<Uint8List> _readPiece(int length) async {
    final request = MediaReadRequest(
      sessionId: id,
      start: _position,
      length: length,
    );
    final bytes = await guardPlatformCall(
      () => _readChannel.invokeMethod<Uint8List>(
        'readFromSession',
        jsonEncode(request.toJson()),
      ),
      _exceptionMapper.map,
    );
    _position += bytes!.length;
    return bytes;
  }
}
