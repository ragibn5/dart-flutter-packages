import 'dart:io';

import 'package:synchronized/synchronized.dart';

/// A data-store backed by a single file.
///
/// All read/write operations are serialized per-instance via an internal
/// lock so concurrent callers are queued and awaited automatically.
class FileStore {
  final _lock = Lock();
  final File _file;

  FileStore(this._file);

  /// Reads the full contents of the storage file as a UTF-8 string.
  ///
  /// Returns `null` when the file does not exist.
  /// Throws on other I/O errors (e.g. permission denied).
  Future<String?> readData() async {
    return _lock.synchronized(() async {
      if (_file.existsSync() == false) {
        return null;
      }

      return _file.readAsStringSync();
    });
  }

  /// Writes [content] to the storage file, overwriting any existing content.
  ///
  /// When [content] is `null` the underlying file is deleted.
  ///
  /// Creates the parent directory (and any ancestors) if it does not exist.
  /// Throws on other I/O errors (e.g. permission denied, path is a directory).
  Future<void> writeData(String? content) async {
    return _lock.synchronized(() async {
      if (content == null) {
        if (_file.existsSync()) {
          _file.deleteSync();
        }
        return;
      }

      if (!_file.parent.existsSync()) {
        _file.parent.createSync(recursive: true);
      }

      _file.writeAsStringSync(content);
    });
  }
}
