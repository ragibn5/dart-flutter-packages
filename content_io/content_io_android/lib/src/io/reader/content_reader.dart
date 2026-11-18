import 'dart:typed_data';

import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:meta/meta.dart';

/// A reader of the bytes behind one URI.
///
/// Implementations:
/// - `FileContentReader`: a file opened by path, read with `dart:io`.
/// - `DescriptorContentReader`: a file descriptor, read with libc over FFI.
/// - `ChannelContentReader`: a platform-side session, read over the method
///   channel.
///
/// Implementations report failures as the plugin's exceptions. Methods must
/// not be called concurrently, or after [close].
abstract class ContentReader {
  /// The id of the reader, used as the id of the session reading it.
  String get id;

  /// The size of the content in bytes, or `null` if unknown.
  int? get length;

  /// Whether [read] and [readAll] accept a `position`.
  ///
  /// `false` for pipes, sockets and platform streams.
  bool get isSeekable;

  /// Reads up to [maxLength] bytes, and moves the current position to the
  /// end of the bytes read.
  ///
  /// Parameters:
  /// - [maxLength]: the maximum number of bytes to read; must be positive.
  /// - [position]: the offset to read from, from the start of the content; must
  ///   not be negative, and requires [isSeekable].
  ///
  /// Returns: the bytes read: fewer than [maxLength] when fewer are available,
  /// and empty at the end of the content.
  ///
  /// Throws:
  /// - [RangeError] if [position] is negative.
  /// - [UnsupportedError] if [position] is given and the reader isn't
  ///   [isSeekable].
  /// - [ContentReadException] if reading fails.
  ///
  /// Note:
  /// If [position] is not provided, reads from the current position: the
  /// start of the content, or where the previous read ended.
  Future<Uint8List> read(int maxLength, {int? position});

  /// Reads to the end of the content, and moves the current position to the
  /// end.
  ///
  /// Parameters:
  /// - [position]: the offset to read from, from the start of the content; must
  ///   not be negative, and requires [isSeekable].
  ///
  /// Returns: the bytes read; empty when already at the end.
  ///
  /// Throws:
  /// - [RangeError] if [position] is negative.
  /// - [UnsupportedError] if [position] is given and the reader isn't
  ///   [isSeekable].
  /// - [ContentReadException] if reading fails.
  ///
  /// Note:
  /// If [position] is not provided, reads from the current position: the
  /// start of the content, or where the previous read ended.
  Future<Uint8List> readAll({int? position});

  /// Releases the resources held by the reader.
  ///
  /// Note:
  /// Called once. Never throws.
  Future<void> close();

  /// Reads from the current position to the end, with repeated [read] calls.
  ///
  /// Parameters:
  /// - [pieceSize]: the number of bytes requested per [read].
  ///
  /// Returns: the bytes read, joined.
  ///
  /// Throws:
  /// - [ContentReadException] if a read fails.
  ///
  /// Note:
  /// When the whole read arrives in one piece, that piece is returned without
  /// copying.
  @protected
  Future<Uint8List> readToEnd(int pieceSize) async {
    final builder = BytesBuilder(copy: false);
    while (true) {
      final piece = await read(pieceSize);
      if (piece.isEmpty) {
        return builder.takeBytes();
      }
      builder.add(piece);
    }
  }
}
