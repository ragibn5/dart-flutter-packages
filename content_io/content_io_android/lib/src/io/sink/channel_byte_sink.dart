import 'dart:math';

import 'package:content_io_android/src/exceptions/content_write_exception.dart';
import 'package:content_io_android/src/io/sink/content_byte_sink.dart';
import 'package:content_io_android/src/utils/platform_call_guarder.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// A [ContentByteSink] for a platform-side write session, written over the
/// method channel.
///
/// Each write takes one or more `writeToSession` calls, of at most
/// [_maxBytesPerCall] bytes each. Closing and aborting go over the same
/// channel, so they run after every write sent before them.
final class ChannelByteSink extends ContentByteSink {
  /// The maximum number of bytes sent per `writeToSession` call.
  static const _maxBytesPerCall = 512 * 1024;

  /// The channel for `writeToSession`, `closeWriteSession` and
  /// `abortWriteSession`, handled off the platform's main thread.
  final MethodChannel _writeChannel;

  /// Maps [PlatformException]s to [ContentWriteException]s.
  final ContentWriteExceptionMapper _exceptionMapper;

  /// The id of the platform-side session.
  @override
  final String id;

  ChannelByteSink({
    required MethodChannel writeChannel,
    required this.id,
    @visibleForTesting
    ContentWriteExceptionMapper exceptionMapper =
        const ContentWriteExceptionMapper(),
  }) : _writeChannel = writeChannel,
       _exceptionMapper = exceptionMapper;

  @override
  Future<void> write(Uint8List bytes) async {
    for (var start = 0; start < bytes.length; start += _maxBytesPerCall) {
      final end = min(start + _maxBytesPerCall, bytes.length);
      await guardPlatformCall(
        _exceptionMapper,
        () => _writeChannel.invokeMethod<void>('writeToSession', {
          'sessionId': id,
          'bytes': Uint8List.sublistView(bytes, start, end),
        }),
      );
    }
  }

  @override
  Future<void> close() {
    return guardPlatformCall(
      _exceptionMapper,
      () => _writeChannel.invokeMethod<void>('closeWriteSession', {
        'sessionId': id,
      }),
    );
  }

  @override
  Future<void> abort() async {
    try {
      await _writeChannel.invokeMethod<void>('abortWriteSession', {
        'sessionId': id,
      });
    } catch (_) {
      // Ignored: [abort] never throws.
    }
  }
}
