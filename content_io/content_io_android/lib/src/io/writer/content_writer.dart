import 'dart:typed_data';

import 'package:content_io_android/src/exceptions/content_write_exception.dart';

/// A writer for the bytes behind one URI.
///
/// Implementations:
/// - `DescriptorContentWriter`: a file descriptor, written with libc over FFI.
/// - `ChannelContentWriter`: a platform-side session, written over the method
///   channel.
///
/// Implementations report failures as the plugin's exceptions. Methods must
/// not be called concurrently, or after [close] or [abort].
abstract class ContentWriter {
  /// The id of the writer, used as the id of the session writing it.
  String get id;

  /// Writes all of [bytes] after what was written before.
  ///
  /// Throws:
  /// - [ContentWriteException] if writing fails; a [NotEnoughSpaceException]
  ///   when the volume is full.
  Future<void> write(Uint8List bytes);

  /// Waits until everything written is on the storage, then releases the
  /// resources held by the writer.
  ///
  /// Throws:
  /// - [ContentWriteException] if the content can't be stored; a
  ///   [NotEnoughSpaceException] when the volume filled up.
  ///
  /// Note:
  /// Called once. The resources are released even when it throws.
  Future<void> close();

  /// Releases the resources held by the writer, without waiting for what was
  /// written to be stored.
  ///
  /// Note:
  /// Called once. Never throws.
  Future<void> abort();
}
