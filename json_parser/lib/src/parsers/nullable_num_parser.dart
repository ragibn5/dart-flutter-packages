import 'package:json_parser/src/types/json_types.dart';
import 'package:parser_core/parser_core.dart';

class NullableNumParser implements Parser<num?, Json> {
  const NullableNumParser();

  @override
  num? decode(Json encoded) {
    if (encoded == null) {
      return null;
    }

    if (encoded is! num) {
      throw StateError('Expected number, but got ${encoded.runtimeType}');
    }

    return encoded;
  }

  @override
  Json encode(num? value) => value;
}
