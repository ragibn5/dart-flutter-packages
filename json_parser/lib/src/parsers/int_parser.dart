import 'package:json_parser/src/errors/json_parse_exception.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:parser_core/parser_core.dart';

class IntParser implements Parser<int, Json> {
  const IntParser();

  @override
  int decode(Json encoded) {
    if (encoded is! num) {
      throw JsonParseException(
        'Expected number, but got ${encoded.runtimeType}',
      );
    }

    return encoded.toInt();
  }

  @override
  Json encode(int value) => value;
}
