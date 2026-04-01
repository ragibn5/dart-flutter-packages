import 'package:json_parser/src/types/json_types.dart';
import 'package:parser/parser.dart';

class BoolParser implements Parser<bool, Json> {
  const BoolParser();

  @override
  bool decode(Json encoded) {
    if (encoded is! bool) {
      throw StateError('Expected bool, but got ${encoded.runtimeType}');
    }

    return encoded;
  }

  @override
  Json encode(bool value) => value;
}
