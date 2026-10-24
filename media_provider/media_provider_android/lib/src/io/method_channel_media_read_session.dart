import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:media_provider_android/src/exceptions/media_read_exception.dart';
import 'package:media_provider_android/src/io/media_read_session.dart';
import 'package:media_provider_android/src/io/native_pread.dart';
import 'package:media_provider_android/src/models/media_read_request.dart';
import 'package:media_provider_android/src/utils/platform_exception_mapper.dart';
import 'package:media_provider_android/src/utils/timing.dart';
import 'package:meta/meta.dart';

/// A [MediaReadSession] backed by a session on the platform side of [_channel].
final class MethodChannelMediaReadSession implements MediaReadSession {
  final MethodChannel _channel;

  /// The channel `readFromSession` is sent on. Experimental: may be a channel
  /// served on a platform background task queue instead of [_channel].
  final MethodChannel _readChannel;
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

  /// Experimental: `/proc/self/fd/<n>` of the platform's open descriptor, or
  /// `null` if it didn't open one. Only valid while the session is open.
  final String? directPath;

  /// Experimental: the number of the platform's open descriptor, or `null` if
  /// it didn't open one. Only valid while the session is open.
  final int? descriptorFd;

  @override
  bool get isClosed => _isClosed;

  /// Completes when the most recent call has finished, successfully or not.
  Future<void> _lastCall = Future.value();

  MethodChannelMediaReadSession({
    required MethodChannel channel,
    MethodChannel? readChannel,
    required this.sessionId,
    required this.contentUri,
    required this.sizeInBytes,
    required this.isSeekable,
    this.directPath,
    this.descriptorFd,
    @visibleForTesting
    MediaReadExceptionMapper errorMapper = const MediaReadExceptionMapper(),
  }) : _channel = channel,
       _readChannel = readChannel ?? channel,
       _mediaReadExceptionMapper = errorMapper;

  @override
  Future<Uint8List> read(int length, {int? position}) {
    if (length <= 0) {
      throw RangeError.range(length, 1, null, 'length');
    }
    if (position != null) {
      RangeError.checkNotNegative(position, 'position');
    }

    final via = _readChannel.name == _channel.name ? '' : 'bg ';
    final label = '[${via}readFromSession start=${position ?? 0}] dart';
    final laps = Laps(label);
    return _serialized(() async {
      laps.lap('wait for previous call');
      if (_isClosed) {
        throw SessionNotFoundException(
          'Session $sessionId is closed',
          sessionId: sessionId,
        );
      }

      try {
        final request = MediaReadRequest(
          sessionId: sessionId,
          start: position ?? 0,
          length: length,
        );
        final encoded = timedSync(
          '$label jsonEncode',
          () => jsonEncode(request.toJson()),
        );
        logMark('$label sent');
        final bytes = await timed(
          '$label invokeMethod round trip',
          () => guardPlatformCall(
            () => _readChannel.invokeMethod<Uint8List>(
              'readFromSession',
              encoded,
            ),
            _mediaReadExceptionMapper.map,
          ),
        );
        logMark('$label reply received');
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
    final s = DateTime.now().millisecondsSinceEpoch;
    var position = start;
    try {
      while (end == null || position < end) {
        final length = end == null ? chunkSize : min(chunkSize, end - position);
        final chunk = await read(length, position: position);
        if (chunk.isEmpty) {
          break;
        }
        position += chunk.length;
        final laps = Laps(
          '[openRead position=${position - chunk.length}] dart',
        );
        yield chunk;
        laps.lap('consumer (yield until resumed)');
      }
    } finally {
      final e = DateTime.now().millisecondsSinceEpoch;
      print('Taken: ${(e - s)}');
      await close();
    }
  }

  @override
  Stream<Uint8List> openReadDirect({
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
    final path = directPath;
    if (path == null) {
      throw UnsupportedError('Session $sessionId has no descriptor path');
    }

    return _readRangeDirect(path, start, end, chunkSize);
  }

  Stream<Uint8List> _readRangeDirect(
    String path,
    int start,
    int? end,
    int chunkSize,
  ) async* {
    final total = Stopwatch()..start();
    final laps = Laps('[openReadDirect $path] dart');
    RandomAccessFile? file;
    var position = start;
    try {
      file = await File(path).open();
      // A fresh open starts at 0, so only seek when needed.
      if (start != 0) {
        await file.setPosition(start);
      }
      laps.lap('open + seek');

      while (end == null || position < end) {
        final length = end == null ? chunkSize : min(chunkSize, end - position);
        final chunk = await file.read(length);
        laps.lap('read ${chunk.length}B at $position');
        if (chunk.isEmpty) {
          break;
        }
        position += chunk.length;
        yield chunk;
        laps.lap('consumer (yield until resumed)');

        // A short read that reached the known size is the end: skip the
        // extra read that would only confirm it.
        final size = sizeInBytes;
        if (chunk.length < length && size != null && position >= size) {
          break;
        }
      }
    } finally {
      // Close ours before the platform closes the descriptor we reopened.
      await file?.close();
      print(
        '[MPTiming] [openReadDirect] dart total: '
        '${total.elapsedMicroseconds}us for ${position - start}B',
      );
      await close();
    }
  }

  @override
  Stream<Uint8List> openReadFfi({
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
    final fd = descriptorFd;
    if (fd == null) {
      throw UnsupportedError('Session $sessionId has no descriptor number');
    }

    return _readRangeFfi(fd, start, end, chunkSize);
  }

  Stream<Uint8List> _readRangeFfi(
    int fd,
    int start,
    int? end,
    int chunkSize,
  ) async* {
    final total = Stopwatch()..start();
    final laps = Laps('[openReadFfi fd=$fd] dart');
    var position = start;
    try {
      while (end == null || position < end) {
        var length = end == null ? chunkSize : min(chunkSize, end - position);
        // Don't allocate past the known end; a read there just returns 0.
        final size = sizeInBytes;
        if (size != null && position < size) {
          length = min(length, size - position);
        }

        final chunk = NativePread.read(fd, length, position);
        laps.lap('pread ${chunk.length}B at $position');
        if (chunk.isEmpty) {
          break;
        }
        position += chunk.length;
        yield chunk;
        laps.lap('consumer (yield until resumed)');
      }
    } finally {
      print(
        '[MPTiming] [openReadFfi] dart total: '
        '${total.elapsedMicroseconds}us for ${position - start}B',
      );
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
