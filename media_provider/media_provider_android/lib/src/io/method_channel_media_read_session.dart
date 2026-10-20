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

  @override
  final String id;

  @override
  final int? size;

  @override
  bool get isClosed => _isClosed;

  /// Whether the session is closed.
  bool _isClosed = false;

  /// Completes when the most recent call has finished, successfully or not.
  Future<void> _lastCall = Future.value();

  MethodChannelMediaReadSession({
    required MethodChannel channel,
    required this.id,
    required this.size,
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
        throw SessionClosedException('Session $id is closed', sessionId: id);
      }

      try {
        final bytes = await guardPlatformCall(
          () => _channel.invokeMethod<Uint8List>('readFromSession', {
            'sessionId': id,
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
          'sessionId': id,
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
