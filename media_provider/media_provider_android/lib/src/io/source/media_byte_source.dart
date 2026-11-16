import 'dart:typed_data';

import 'package:media_provider_android/src/exceptions/media_read_exception.dart';
import 'package:meta/meta.dart';

/// A source of the bytes of one media item.
///
/// Implementations:
/// - `FileByteSource`: a file opened by path, read with `dart:io`.
/// - `DescriptorByteSource`: a file descriptor, read with libc over FFI.
/// - `ChannelByteSource`: a platform-side session, read over the method
///   channel.
///
/// Implementations report failures as the plugin's exceptions. Methods must
/// not be called concurrently, or after [close].
abstract class MediaByteSource {
  /// The id of the source, used as the id of the session reading it.
  String get id;

  /// The size of the source in bytes, or `null` if unknown.
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
  /// - [position]: the offset to read from, from the start of the source; must
  ///   not be negative, and requires [isSeekable].
  ///
  /// Returns: the bytes read: fewer than [maxLength] when fewer are available,
  /// and empty at the end of the source.
  ///
  /// Throws:
  /// - [RangeError] if [position] is negative.
  /// - [UnsupportedError] if [position] is given and the source isn't
  ///   [isSeekable].
  /// - [MediaReadException] if reading fails.
  ///
  /// Note:
  /// If [position] is not provided, reads from the current position: the
  /// start of the source, or where the previous read ended.
  Future<Uint8List> read(int maxLength, {int? position});

  /// Reads to the end of the source, and moves the current position to the
  /// end.
  ///
  /// Parameters:
  /// - [position]: the offset to read from, from the start of the source; must
  ///   not be negative, and requires [isSeekable].
  ///
  /// Returns: the bytes read; empty when already at the end.
  ///
  /// Throws:
  /// - [RangeError] if [position] is negative.
  /// - [UnsupportedError] if [position] is given and the source isn't
  ///   [isSeekable].
  /// - [MediaReadException] if reading fails.
  ///
  /// Note:
  /// If [position] is not provided, reads from the current position: the
  /// start of the source, or where the previous read ended.
  Future<Uint8List> readAll({int? position});

  /// Releases the resources held by the source.
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
  /// - [MediaReadException] if a read fails.
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
