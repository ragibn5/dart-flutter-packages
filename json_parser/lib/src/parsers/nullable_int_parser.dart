import 'package:json_parser/src/types/json_types.dart';
import 'package:parser/parser.dart';

class NullableIntParser implements Parser<int?, Json> {
  const NullableIntParser();

  @override
  int? decode(Json encoded) {
    if (encoded == null) {
      return null;
    }

    if (encoded is! num) {
      throw StateError('Expected number, but got ${encoded.runtimeType}');
    }

    return encoded.toInt();
  }

  @override
  Json encode(int? value) => value;
}
