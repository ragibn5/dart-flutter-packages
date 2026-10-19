import 'dart:typed_data';

import 'package:media_provider_android/src/exceptions/media_read_exception.dart';

/// A handle for reading one `MediaStore` item.
abstract interface class MediaReadSession {
  /// The chunk size [openRead] uses by default, in bytes.
  static const defaultChunkSize = 512 * 1024;

  /// The id of this session.
  String get id;

  /// The size of the item in bytes, or `null` when the platform can't tell.
  int? get size;

  /// Whether the session is closed.
  bool get isClosed;

  /// Reads up to [length] bytes.
  ///
  /// Without [position], reads from the current position and advances it.
  /// With [position], reads from that offset without moving the current
  /// position; this needs a seekable descriptor and throws
  /// [UnsupportedOperationException] otherwise.
  ///
  /// May return fewer than [length] bytes. An empty result means there is
  /// nothing left to read.
  ///
  /// Calls are serialized: a read starts only after the previous one ends.
  Future<Uint8List> read(int length, {int? position});

  /// Streams the bytes in the range \[[start], [end]), or up to the end of the
  /// item when [end] is `null`, in chunks of at most [chunkSize] bytes.
  ///
  /// Reads only while the stream is listened to and not paused. The session
  /// is closed when the stream is done, fails or is cancelled. Reading isn't
  /// started until the stream is listened to, so an unlistened stream leaves
  /// the session open until [close] or the idle timeout.
  ///
  /// Uses positional reads, so it doesn't depend on, or move, the position
  /// used by [read] without a position.
  Stream<Uint8List> openRead({
    int start = 0,
    int? end,
    int chunkSize = defaultChunkSize,
  });

  /// Closes the session and releases the descriptor.
  ///
  /// Waits for an in-flight read to finish first. Closing a closed session
  /// does nothing. Never throws.
  Future<void> close();
}
