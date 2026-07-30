import 'package:json_parser/src/types/json_types.dart';
import 'package:parser_core/parser_core.dart';

class NullableStringParser implements Parser<String?, Json> {
  const NullableStringParser();

  @override
  String? decode(Json encoded) {
    if (encoded is! String?) {
      throw StateError('Expected String? but got ${encoded.runtimeType}');
    }

    return encoded;
  }

  @override
  Json encode(String? value) => value;
}
