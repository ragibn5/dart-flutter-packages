import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dlogger/src/models/result.dart';
import 'package:dlogger/src/services/file_writer.dart';

/// Default implementation of [FileWriter].
class DefaultFileWriter implements FileWriter {
  final String separator;

  /// Creates a new instance of type [DefaultFileWriter].
  const DefaultFileWriter(this.separator);

  @override
  Result<void> writeSync(
    File file,
    String content, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = true,
  }) {
    try {
      final parent = file.parent;
      if (!parent.existsSync()) {
        parent.createSync(recursive: true);
      }

      file.writeAsStringSync(
        '$content$separator',
        mode: mode,
        encoding: encoding,
        flush: flush,
      );

      return Result.success(null);
    } catch (e, st) {
      return Result.exception(e, st);
    }
  }
}
