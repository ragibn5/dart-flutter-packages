import 'package:json_parser/src/types/json_types.dart';
import 'package:parser/parser.dart';

class NullableBoolParser implements Parser<bool?, Json> {
  const NullableBoolParser();

  @override
  bool? decode(Json encoded) {
    if (encoded == null) {
      return null;
    }

    if (encoded is! bool) {
      throw StateError('Expected bool?, but got ${encoded.runtimeType}');
    }

    return encoded;
  }

  @override
  Json encode(bool? value) => value;
}
