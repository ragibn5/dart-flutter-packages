import 'dart:async';
import 'dart:typed_data';

import 'package:content_io_android/src/exceptions/content_write_exception.dart';
import 'package:content_io_android/src/io/writer/content_writer.dart';
import 'package:meta/meta.dart';

/// A single-use writer for the content behind one URI.
///
/// Write with [write] as often as needed, then [close] to store what was
/// written, or [abort] to give up; or let [writeStream] do all of it.
/// Writing after either throws a [WriteSessionNotFoundException].
class ContentWriteSession {
  /// Whether the session is closed.
  bool _isClosed = false;

  /// Completes when the most recently queued call completes, whether it
  /// succeeded or failed.
  Future<void> _lastCall = Future.value();

  /// The writer the session writes to.
  final ContentWriter _writer;

  /// Creates a session that writes to [writer].
  ///
  /// Parameters:
  /// - [writer]: the writer to write to; the session closes it.
  @internal
  ContentWriteSession({required ContentWriter writer}) : _writer = writer;

  /// The id of this session.
  String get sessionId => _writer.id;

  /// Whether the session is closed.
  bool get isClosed => _isClosed;

  /// Writes all of [bytes] after what was written before.
  ///
  /// Throws:
  /// - [ContentWriteException] if writing fails; a [NotEnoughSpaceException]
  ///   when the volume is full.
  ///
  /// Note:
  /// - Waits for the calls before it.
  /// - The session stays open after a failure: [abort] it, or [close] it to
  ///   keep what was written.
  Future<void> write(List<int> bytes) {
    return _serialized(() {
      _checkOpen();
      return _writer.write(
        bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      );
    });
  }

  /// Writes every chunk of [stream], then closes the session.
  ///
  /// Throws:
  /// - [ContentWriteException] if writing or closing fails.
  /// - Whatever [stream] fails with.
  ///
  /// Note:
  /// When a chunk can't be written or [stream] fails, the session is aborted
  /// before the failure is rethrown.
  Future<void> writeStream(Stream<List<int>> stream) async {
    try {
      await for (final chunk in stream) {
        await write(chunk);
      }
    } catch (_) {
      await abort();
      rethrow;
    }
    await close();
  }

  /// Waits until everything written is on the storage, then closes the
  /// session.
  ///
  /// Throws:
  /// - [ContentWriteException] if the content can't be stored; a
  ///   [NotEnoughSpaceException] when the volume filled up, which the storage
  ///   may report only now.
  ///
  /// Note:
  /// - Waits for an in-progress write to complete.
  /// - The session is closed even when it throws.
  /// - Has no effect if the session is already closed.
  Future<void> close() {
    return _serialized(() async {
      if (_isClosed) {
        return;
      }
      _isClosed = true;
      await _writer.close();
    });
  }

  /// Closes the session without waiting for what was written to be stored.
  ///
  /// Note:
  /// - What was written may or may not be stored: the content may be left
  ///   partly written, or, opened with `WriteMode.truncate`, empty.
  /// - Waits for an in-progress write to complete.
  /// - Has no effect if the session is already closed.
  /// - Never throws.
  Future<void> abort() {
    return _serialized(() async {
      if (_isClosed) {
        return;
      }
      _isClosed = true;
      await _writer.abort();
    });
  }

  void _checkOpen() {
    if (_isClosed) {
      throw WriteSessionNotFoundException(
        'Session $sessionId is closed',
        sessionId: sessionId,
      );
    }
  }

  /// Runs [call] after all previously queued calls have completed.
  ///
  /// Parameters:
  /// - [call]: the operation to queue.
  ///
  /// Returns: the result of [call].
  Future<T> _serialized<T>(Future<T> Function() call) {
    final result = _lastCall.then((_) => call());
    _lastCall = result.then<void>((_) {}, onError: (_) {});
    return result;
  }
}
