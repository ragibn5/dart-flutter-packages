import 'dart:async';
import 'dart:io';

import 'package:dlogger/src/loggers/logger.dart';
import 'package:dlogger/src/models/log_data.dart';
import 'package:dlogger/src/services/default_file_writer.dart';
import 'package:dlogger/src/services/default_log_formatter.dart';
import 'package:dlogger/src/services/file_writer.dart';
import 'package:dlogger/src/services/log_formatter.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

/// A logger that writes logs to files.
class FileLogger implements Logger {
  /// {@template field_log_dir}
  /// The directory where new log files will be created.
  /// {@endtemplate}
  final Directory _logDirectory;

  /// {@template field_log_file_name_builder}
  /// A lambda function that generates a file name based on [LogData].
  /// {@endtemplate}
  final String Function(LogData data) _fileNameBuilder;

  /// {@template field_formatter}
  /// A formatter to format the log message.
  /// {@endtemplate}
  final LogFormatter _formatter;

  /// {@template field_file_writer}
  /// A writer to write the log message to a file.
  /// {@endtemplate}
  final FileWriter _fileWriter;

  /// {@template field_stream_controller}
  /// A stream controller to listen to the log stream.
  /// {@endtemplate}
  final StreamController<LogData> _streamController;

  /// Create an instance of [FileLogger] with an optional formatter and a
  /// filter.
  /// - [logDirectory]:
  ///   {@macro field_log_dir}
  /// - [fileNameBuilder]:
  ///   {@macro field_log_file_name_builder}
  /// - [formatter]:
  ///   {@macro field_formatter}
  FileLogger({
    required Directory logDirectory,
    required String Function(LogData data) fileNameBuilder,
    LogFormatter formatter = const DefaultLogFormatter(),
  })  : _logDirectory = logDirectory,
        _fileNameBuilder = fileNameBuilder,
        _formatter = formatter,
        _fileWriter = DefaultFileWriter(Platform.isWindows ? '\r\n' : '\n'),
        _streamController = StreamController() {
    _startListener();
  }

  @visibleForTesting
  FileLogger.test(
    this._logDirectory,
    this._fileNameBuilder,
    this._formatter,
    this._fileWriter,
    this._streamController,
  ) {
    _startListener();
  }

  @override
  void log(LogData data) {
    if (_streamController.isClosed || _streamController.isPaused) {
      return;
    }

    _streamController.add(data);
  }

  /// Dispose the logger and release all the internal system resources.
  ///
  /// Please note, the logger is no longer usable after calling this method.
  /// If you want to use the logger again, you need to create a new instance.
  void dispose() {
    _streamController.close();
  }

  void _startListener() {
    _streamController.stream.listen((data) async {
      final fileName = _fileNameBuilder(data);
      final file = File('${_logDirectory.path}${path.separator}$fileName');
      _fileWriter
          .writeSync(file, _formatter.format(data), mode: FileMode.append)
          .fold(
            onSuccess: (_) {
              // no-op
            },
            onFailure: (es) =>
                print('Error writing to file: ${es.$1}\n${es.$2}'),
          );
    });
  }

  @visibleForTesting
  Directory get logDirectory => _logDirectory;

  @visibleForTesting
  Function get fileNameBuilder => _fileNameBuilder;
}
