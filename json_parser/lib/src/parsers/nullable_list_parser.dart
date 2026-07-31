import 'package:json_parser/src/errors/json_parse_exception.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:json_parser/src/utils/decode_with_path.dart';
import 'package:parser_core/parser_core.dart';

class NullableListParser<T> implements Parser<List<T>?, Json> {
  final Parser<T, Json> itemParser;

  const NullableListParser(this.itemParser);

  @override
  List<T>? decode(Json encoded) {
    if (encoded == null) {
      return null;
    }

    if (encoded is! List) {
      throw JsonParseException(
        'Expected JSON list, but got ${encoded.runtimeType}',
      );
    }

    return [
      for (var i = 0; i < encoded.length; i++)
        decodeWithPath(() => itemParser.decode(encoded[i]), i),
    ];
  }

  @override
  Json encode(List<T>? value) {
    return value?.map(itemParser.encode).toList();
  }
}
