import 'dart:math';

import 'package:flutter/services.dart';
import 'package:media_provider_android/src/exceptions/media_read_exception.dart';
import 'package:media_provider_android/src/io/media_read_session.dart';
import 'package:media_provider_android/src/utils/platform_exception_mapper.dart';
import 'package:meta/meta.dart';

/// A [MediaReadSession] backed by a session on the platform side of [_channel].
final class MethodChannelMediaReadSession implements MediaReadSession {
  final MethodChannel _channel;
  final MediaReadExceptionMapper _mediaReadExceptionMapper;

  bool _isClosed = false;

  @override
  final String sessionId;

  @override
  final String contentUri;

  @override
  final int? sizeInBytes;

  @override
  final bool isSeekable;

  @override
  bool get isClosed => _isClosed;

  /// Completes when the most recent call has finished, successfully or not.
  Future<void> _lastCall = Future.value();

  MethodChannelMediaReadSession({
    required MethodChannel channel,
    required this.sessionId,
    required this.contentUri,
    required this.sizeInBytes,
    required this.isSeekable,
    @visibleForTesting
    MediaReadExceptionMapper errorMapper = const MediaReadExceptionMapper(),
  }) : _channel = channel,
       _mediaReadExceptionMapper = errorMapper;

  @override
  Future<Uint8List> read(int length, {int? position}) {
    if (length <= 0) {
      throw RangeError.range(length, 1, null, 'length');
    }
    if (position != null) {
      RangeError.checkNotNegative(position, 'position');
    }

    return _serialized(() async {
      if (_isClosed) {
        throw SessionClosedException(
          'Session $sessionId is closed',
          sessionId: sessionId,
        );
      }

      try {
        final bytes = await guardPlatformCall(
          () => _channel.invokeMethod<Uint8List>('readFromSession', {
            'sessionId': sessionId,
            'length': length,
            'position': position,
          }),
          _mediaReadExceptionMapper.map,
        );
        return bytes!;
      } catch (_) {
        // The platform closes a session on any failed read; mirror that here.
        _isClosed = true;
        rethrow;
      }
    });
  }

  @override
  Stream<Uint8List> openRead({
    int start = 0,
    int? end,
    int chunkSize = MediaReadSession.defaultChunkSize,
  }) {
    RangeError.checkNotNegative(start, 'start');
    if (end != null && end < start) {
      throw RangeError.range(end, start, null, 'end');
    }
    if (chunkSize <= 0) {
      throw RangeError.range(chunkSize, 1, null, 'chunkSize');
    }

    return _readRange(start, end, chunkSize);
  }

  Stream<Uint8List> _readRange(int start, int? end, int chunkSize) async* {
    var position = start;
    try {
      while (end == null || position < end) {
        final length = end == null ? chunkSize : min(chunkSize, end - position);
        final chunk = await read(length, position: position);
        if (chunk.isEmpty) {
          break;
        }
        position += chunk.length;
        yield chunk;
      }
    } finally {
      await close();
    }
  }

  @override
  Future<void> close() {
    return _serialized(() async {
      if (_isClosed) {
        return;
      }
      _isClosed = true;

      try {
        await _channel.invokeMethod<void>('closeReadSession', {
          'sessionId': sessionId,
        });
      } catch (_) {
        // Nothing the caller could do about it. The platform also closes the
        // session on its own once it goes idle.
      }
    });
  }

  /// Runs [call] once every earlier call has finished.
  Future<T> _serialized<T>(Future<T> Function() call) {
    final result = _lastCall.then((_) => call());
    _lastCall = result.then<void>((_) {}, onError: (_) {});
    return result;
  }
}
