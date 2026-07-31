import 'package:json_parser/src/errors/json_parse_exception.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:parser_core/parser_core.dart';

class NullableBoolParser implements Parser<bool?, Json> {
  const NullableBoolParser();

  @override
  bool? decode(Json encoded) {
    if (encoded == null) {
      return null;
    }

    if (encoded is! bool) {
      throw JsonParseException(
        'Expected bool?, but got ${encoded.runtimeType}',
      );
    }

    return encoded;
  }

  @override
  Json encode(bool? value) => value;
}
