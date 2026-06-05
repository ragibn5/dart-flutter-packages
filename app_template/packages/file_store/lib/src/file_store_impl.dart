import 'dart:async';
import 'dart:io';

import 'package:file_store/src/file_store.dart';

class FileStoreImpl extends FileStore {
  final File storageFile;

  FileStoreImpl(this.storageFile);

  @override
  Future<File> getStorageFile() async {
    return storageFile;
  }
}
