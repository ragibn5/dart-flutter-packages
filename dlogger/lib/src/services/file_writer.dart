import 'dart:convert';
import 'dart:io';

import 'package:dlogger/src/models/result.dart';

/// A file writer used to write a string to a given file.
abstract interface class FileWriter {
  /// Writes the given bytes to the given file.
  ///
  /// - [file]: The file to write to.
  /// - [bytes]: The bytes to write.
  /// - [mode]: The mode to use when writing the file.
  /// - [flush]: Whether to flush the file after writing.
  ///
  /// Returns A [Result] indicating the success or failure of the operation.
  Result<void> writeSync(
    File file,
    String content, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = true,
  });
}
