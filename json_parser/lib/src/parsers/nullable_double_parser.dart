import 'package:json_parser/src/errors/json_parse_exception.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:parser_core/parser_core.dart';

class NullableDoubleParser implements Parser<double?, Json> {
  const NullableDoubleParser();

  @override
  double? decode(Json encoded) {
    if (encoded == null) {
      return null;
    }

    if (encoded is! num) {
      throw JsonParseException(
        'Expected number, but got ${encoded.runtimeType}',
      );
    }

    return encoded.toDouble();
  }

  @override
  Json encode(double? value) => value;
}
