import 'package:json_parser/src/types/json_types.dart';
import 'package:parser/parser.dart';

class IntParser implements Parser<int, Json> {
  const IntParser();

  @override
  int decode(Json encoded) {
    if (encoded is! num) {
      throw StateError('Expected number, but got ${encoded.runtimeType}');
    }

    return encoded.toInt();
  }

  @override
  Json encode(int value) => value;
}
