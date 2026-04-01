import 'package:json_parser/src/types/json_types.dart';
import 'package:parser/parser.dart';

class ListParser<T> implements Parser<List<T>, Json> {
  final Parser<T, Json> itemParser;

  const ListParser(this.itemParser);

  @override
  List<T> decode(Json encoded) {
    if (encoded is! List) {
      throw StateError('Expected JSON list, but got ${encoded.runtimeType}');
    }

    return encoded.map(itemParser.decode).toList();
  }

  @override
  Json encode(List<T> value) {
    return value.map(itemParser.encode).toList();
  }
}
