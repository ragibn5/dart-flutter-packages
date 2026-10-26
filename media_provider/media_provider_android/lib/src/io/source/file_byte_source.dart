import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:media_provider_android/src/exceptions/media_read_exception.dart';
import 'package:media_provider_android/src/io/source/media_byte_source.dart';

/// A [MediaByteSource] for a file opened by path, read with `dart:io`.
///
/// Makes no platform calls. Reads run on `dart:io`'s IO threads and don't
/// block the calling isolate.
final class FileByteSource extends MediaByteSource {
  /// The minimum number of bytes [readAll] requests per read.
  static const _minPieceSize = 64 * 1024;

  /// The open file. Its own position is the source's current position.
  final RandomAccessFile _file;

  @override
  final String id;

  @override
  final int length;

  FileByteSource._(this.id, this._file, this.length);

  /// Opens the file at [path] for reading.
  ///
  /// Parameters:
  /// - [id]: the id of the source.
  /// - [path]: the absolute path of the file.
  ///
  /// Returns: the source for the open file.
  ///
  /// Throws:
  /// - [FileSystemException] if the file can't be opened, for example when the
  ///   app may not read it via the path.
  static Future<FileByteSource> open({
    required String id,
    required String path,
  }) async {
    final file = await File(path).open();
    try {
      return FileByteSource._(id, file, await file.length());
    } catch (_) {
      await file.close();
      rethrow;
    }
  }

  @override
  bool get isSeekable => true;

  @override
  Future<Uint8List> read(int maxLength, {int? position}) async {
    try {
      if (position != null) {
        await _seek(position);
      }
      return await _file.read(maxLength);
    } on FileSystemException catch (e, stackTrace) {
      Error.throwWithStackTrace(ReadException(e.toString()), stackTrace);
    }
  }

  @override
  Future<Uint8List> readAll({int? position}) async {
    final int start;
    try {
      if (position != null) {
        await _seek(position);
        start = position;
      } else {
        start = await _file.position();
      }
    } on FileSystemException catch (e, stackTrace) {
      Error.throwWithStackTrace(ReadException(e.toString()), stackTrace);
    }

    // Requests the remaining bytes in one read; an empty read marks the end.
    return readToEnd(max(length - start, _minPieceSize));
  }

  @override
  Future<void> close() async {
    try {
      await _file.close();
    } on FileSystemException {
      // Ignored: [close] never throws.
    }
  }

  /// Moves the file's position to [position].
  ///
  /// Throws:
  /// - [RangeError] if [position] is negative.
  /// - [FileSystemException] if the position can't be set.
  Future<void> _seek(int position) async {
    RangeError.checkNotNegative(position, 'position');
    await _file.setPosition(position);
  }
}
