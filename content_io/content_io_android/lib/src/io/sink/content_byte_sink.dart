import 'dart:typed_data';

import 'package:content_io_android/src/exceptions/content_write_exception.dart';

/// A sink for the bytes behind one URI.
///
/// Implementations:
/// - `DescriptorByteSink`: a file descriptor, written with libc over FFI.
/// - `ChannelByteSink`: a platform-side session, written over the method
///   channel.
///
/// Implementations report failures as the plugin's exceptions. Methods must
/// not be called concurrently, or after [close] or [abort].
abstract class ContentByteSink {
  /// The id of the sink, used as the id of the session writing it.
  String get id;

  /// Writes all of [bytes] after what was written before.
  ///
  /// Throws:
  /// - [ContentWriteException] if writing fails; a [NotEnoughSpaceException]
  ///   when the volume is full.
  Future<void> write(Uint8List bytes);

  /// Waits until everything written is on the storage, then releases the
  /// resources held by the sink.
  ///
  /// Throws:
  /// - [ContentWriteException] if the content can't be stored; a
  ///   [NotEnoughSpaceException] when the volume filled up.
  ///
  /// Note:
  /// Called once. The resources are released even when it throws.
  Future<void> close();

  /// Releases the resources held by the sink, without waiting for what was
  /// written to be stored.
  ///
  /// Note:
  /// Called once. Never throws.
  Future<void> abort();
}
