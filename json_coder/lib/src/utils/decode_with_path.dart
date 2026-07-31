import 'package:json_coder/src/errors/json_parse_exception.dart';

/// Decodes with [decode], and if it throws a [JsonParseException],
/// rethrows it with [segment] prepended to the failure path.
///
/// Used by composite parsers to report the location of the failure.
T decodeWithPath<T>(T Function() decode, Object? segment) {
  try {
    return decode();
  } on JsonParseException catch (e) {
    throw JsonParseException(e.message, [segment, ...e.path]);
  }
}
