import 'dart:developer';
import 'dart:io';

import 'package:meta/meta.dart';

/// The base class for file based data storage.
abstract class FileStore {
  @protected
  Future<File> getStorageFile();

  @protected
  Future<String?> readData() async {
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
  }

  @protected
  Future<bool> writeData(String? content) async {
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
  }
}
