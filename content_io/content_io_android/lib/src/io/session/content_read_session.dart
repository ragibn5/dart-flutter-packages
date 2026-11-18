import 'dart:typed_data';

import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:content_io_android/src/io/reader/content_reader.dart';
import 'package:meta/meta.dart';

/// A single-use reader for the content behind one URI.
///
/// A session is read once, from start to end, by either [openRead] or
/// [readAsBytes]. Both close the session when they finish. Calling either a
/// second time throws a [StateError].
class ContentReadSession {
  /// The default chunk size of [openRead], in bytes.
  static const defaultChunkSize = 512 * 1024;

  /// Whether [openRead] or [readAsBytes] has been called.
  bool _isUsed = false;

  /// Whether the session is closed.
  bool _isClosed = false;

  /// Completes when the most recently queued call completes, whether it
  /// succeeded or failed.
  Future<void> _lastCall = Future.value();

  /// The reader the session reads from.
  final ContentReader _reader;

  /// Creates a session that reads from [reader].
  ///
  /// Parameters:
  /// - [reader]: the reader to read from; the session closes it.
  @internal
  ContentReadSession({required ContentReader reader}) : _reader = reader;

  /// The id of this session.
  String get sessionId => _reader.id;

  /// The size of the content in bytes, or `null` if unknown.
  int? get sizeInBytes => _reader.length;

  /// Whether the session is closed.
  bool get isClosed => _isClosed;

  /// Streams all of the content.
  ///
  /// Parameters:
  /// - [chunkSize]: the maximum size of each chunk, in bytes; must be positive.
  ///
  /// Returns: a single-subscription stream of the content's bytes. Read
  /// failures are delivered on it as [ContentReadException]s.
  ///
  /// Throws:
  /// - [RangeError] if [chunkSize] isn't positive.
  /// - [StateError] if the session was already read.
  ///
  /// Note:
  /// - Reading starts when the stream is listened to, and stops while the
  ///   subscription is paused.
  /// - The session closes when the stream completes, fails or is cancelled.
  /// - A stream that is never listened to leaves the session open until
  ///   [close] is called.
  Stream<Uint8List> openRead({int chunkSize = defaultChunkSize}) {
    if (chunkSize <= 0) {
      throw RangeError.range(chunkSize, 1, null, 'chunkSize');
    }

    _checkUsed();

    return _readChunks(chunkSize);
  }

  /// Reads all of the content into memory, then closes the session.
  ///
  /// Returns: the content's bytes.
  ///
  /// Throws:
  /// - [ContentReadException] if reading fails.
  /// - [StateError] if the session was already read.
  ///
  /// Note:
  /// The returned list holds all of the content, so large content can cause
  /// an [OutOfMemoryError]. Use [openRead] for large content, such as videos;
  /// [sizeInBytes] gives the size when known.
  Future<Uint8List> readAsBytes() async {
    _checkUsed();

    try {
      return await _serialized(() {
        _checkOpen();
        return _reader.readAll();
      });
    } finally {
      await close();
    }
  }

  /// Closes the session and releases its resources.
  ///
  /// Note:
  /// - Waits for an in-progress read to complete.
  /// - Has no effect if the session is already closed.
  /// - Never throws.
  Future<void> close() {
    return _serialized(() async {
      if (_isClosed) {
        return;
      }
      _isClosed = true;
      await _reader.close();
    });
  }

  Stream<Uint8List> _readChunks(int chunkSize) async* {
    try {
      while (true) {
        final chunk = await _serialized(() {
          _checkOpen();
          return _reader.read(chunkSize);
        });
        if (chunk.isEmpty) {
          break;
        }
        yield chunk;
      }
    } finally {
      await close();
    }
  }

  void _checkUsed() {
    if (_isUsed) {
      throw StateError('Session $sessionId was already read');
    }
    _isUsed = true;
  }

  void _checkOpen() {
    if (_isClosed) {
      throw SessionNotFoundException(
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
