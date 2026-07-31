import 'package:json_coder/src/errors/json_parse_exception.dart';
import 'package:json_coder/src/types/json_types.dart';
import 'package:parser_core/parser_core.dart';

class StringParser implements Parser<String, Json> {
  const StringParser();

  @override
  String decode(Json encoded) {
    if (encoded is! String) {
      throw JsonParseException(
        'Expected String, but got ${encoded.runtimeType}',
      );
    }

    return encoded;
  }

  @override
  Json encode(String value) => value;
}
