import 'dart:convert';

import 'package:loghub/src/models/log_data.dart';
import 'package:loghub/src/services/log_formatter.dart';

/// Default implementation of [LogFormatter].
class DefaultLogFormatter implements LogFormatter {
  /// {@template field_pretty_print_extras}
  /// Whether the extras should be pretty-printed.
  /// {@endtemplate}
  final bool prettyPrintExtras;

  /// Creates a new instance of type [DefaultLogFormatter].
  /// - [prettyPrintExtras]:
  ///   {@macro field_pretty_print_extras}
  const DefaultLogFormatter({this.prettyPrintExtras = true});

  @override
  String format(LogData data) {
    final stampString = data.stamp.toString().trim().padRight(32);
    final levelString = data.level.name.toUpperCase().trim().padRight(8);
    final errorString = _getOrEmpty(data.error, prefix: '\n');
    final stackTraceString = _getOrEmpty(data.stackTrace, prefix: '\n');
    final extrasString = _buildExtra(data.extras);

    // ignore: lines_longer_than_80_chars
    return '$stampString $levelString ${data.message}$errorString$stackTraceString$extrasString';
  }

  String _buildExtra(Map<String, dynamic>? extras) {
    if (extras == null || extras.isEmpty) {
      return '';
    }

    final extrasString = JsonEncoder.withIndent(
      prettyPrintExtras ? ' ' : null,
      (o) => o.toString(),
    ).convert(extras);

    return _getOrEmpty(extrasString, prefix: '\n');
  }

  String _getOrEmpty(dynamic value, {String prefix = ''}) =>
      value != null ? '$prefix${value.toString().trim()}' : '';
}
