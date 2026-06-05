import 'dart:developer';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:mutex/mutex.dart';

/// A data-store backed by a single file.
///
/// All read/write operations are serialized per-instance via an internal
/// mutex so concurrent callers are queued and awaited automatically.
abstract class FileStore {
  final _mutex = Mutex();

  /// Returns the file used for read/write operations.
  ///
  /// Subclasses must implement this to provide the target file.
  /// The library will try to create the file if it does not yet exist.
  /// See [readData] and [writeData] for more details.
  @visibleForOverriding
  Future<File> getStorageFile();

  /// Reads the full contents of the storage file as a UTF-8 string.
  ///
  /// Returns `null` when the file does not exist or when an error occurs.
  Future<String?> readData() async {
    return _mutex.synchronized(() async {
      try {
        final file = await getStorageFile();
        if (file.existsSync() == false) {
          return null;
        } else {
          return await file.readAsString();
        }
      } catch (e, st) {
        log(e.toString(), stackTrace: st);
        return null;
      }
    });
  }

  /// Writes [content] to the storage file.
  ///
  /// Returns `true` on success and `false` on error.
  ///
  /// Note:
  /// When [content] is `null` the underlying file is deleted.
  Future<bool> writeData(String? content) async {
    return _mutex.synchronized(() async {
      try {
        final file = await getStorageFile();
        if (content == null) {
          await file.delete();
        } else {
          await file.writeAsString(content);
        }
        return true;
      } catch (e, st) {
        log(e.toString(), stackTrace: st);
        return false;
      }
    });
  }
}
