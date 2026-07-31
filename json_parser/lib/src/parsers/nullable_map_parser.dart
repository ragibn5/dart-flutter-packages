import 'package:json_parser/src/errors/json_parse_exception.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:json_parser/src/utils/decode_with_path.dart';
import 'package:parser_core/parser_core.dart';

class NullableMapParser<K, V> implements Parser<Map<K, V>?, Json> {
  final Parser<K, Json> keyParser;
  final Parser<V, Json> valueParser;

  const NullableMapParser({
    required this.keyParser,
    required this.valueParser,
  });

  @override
  Map<K, V>? decode(Json encoded) {
    if (encoded == null) {
      return null;
    }

    if (encoded is! Map) {
      throw JsonParseException(
        'Expected JSON map, but got ${encoded.runtimeType}',
      );
    }

    final map = encoded.cast<Json, Json>();
    return map.map(
      (key, value) => MapEntry(
        decodeWithPath(() => keyParser.decode(key), key),
        decodeWithPath(() => valueParser.decode(value), key),
      ),
    );
  }

  @override
  Json encode(Map<K, V>? value) {
    return value?.map(
      (key, val) => MapEntry(
        keyParser.encode(key),
        valueParser.encode(val),
      ),
    );
  }
}
