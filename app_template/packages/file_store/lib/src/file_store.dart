import 'dart:io';

import 'package:meta/meta.dart';
import 'package:mutex/mutex.dart';

/// A data-store backed by a single file.
///
/// All read/write operations are serialized per-instance via an internal
/// mutex so concurrent callers are queued and awaited automatically.
class FileStore {
  final Mutex _mutex;
  final File _file;

  FileStore(File file) : this._(Mutex(), file);

  @visibleForTesting
  FileStore.test(Mutex mutex, File file) : this._(mutex, file);

  FileStore._(this._mutex, this._file);

  /// Reads the full contents of the storage file as a UTF-8 string.
  ///
  /// Returns `null` when the file does not exist.
  /// Throws on other I/O errors (e.g. permission denied).
  Future<String?> readData() async {
    return _mutex.synchronized(() async {
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
    return _mutex.synchronized(() async {
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
