import 'package:json_parser/src/types/json_types.dart';
import 'package:parser/parser.dart';

class StringParser implements Parser<String, Json> {
  const StringParser();

  @override
  String decode(Json encoded) {
    if (encoded is! String) {
      throw StateError('Expected String but got ${encoded.runtimeType}');
    }

    return encoded;
  }

  @override
  Json encode(String value) => value;
}
