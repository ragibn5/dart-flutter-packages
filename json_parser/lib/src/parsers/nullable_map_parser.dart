import 'package:json_parser/src/types/json_types.dart';
import 'package:parser/parser.dart';

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
      throw StateError('Expected JSON map, but got ${encoded.runtimeType}');
    }

    final map = encoded.cast<Json, Json>();
    return map.map(
      (key, value) => MapEntry(
        keyParser.decode(key),
        valueParser.decode(value),
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
