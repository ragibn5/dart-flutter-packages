import 'package:json_annotation/json_annotation.dart';

/// How a write session treats the content already there.
@JsonEnum()
enum WriteMode {
  /// Replaces the content: it's emptied when the session opens.
  @JsonValue('truncate')
  truncate,

  /// Keeps the content, and writes after its end.
  @JsonValue('append')
  append,
}
