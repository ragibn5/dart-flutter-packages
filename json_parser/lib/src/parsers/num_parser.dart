import 'package:json_parser/src/errors/json_parse_exception.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:parser_core/parser_core.dart';

class NumParser implements Parser<num, Json> {
  const NumParser();

  @override
  num decode(Json encoded) {
    if (encoded is! num) {
      throw JsonParseException(
        'Expected number, but got ${encoded.runtimeType}',
      );
    }

    return encoded;
  }

  @override
  Json encode(num value) => value;
}
