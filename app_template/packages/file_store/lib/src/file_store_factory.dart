import 'dart:io';

import 'package:file_store/src/file_store.dart';
import 'package:file_store/src/file_store_impl.dart';

class FileStoreFactory {
  FileStore create(File storageFile) {
    return FileStoreImpl(storageFile);
  }
}
