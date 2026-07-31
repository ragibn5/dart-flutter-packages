import 'package:json_parser/src/parsers/bool_parser.dart';
import 'package:json_parser/src/parsers/double_parser.dart';
import 'package:json_parser/src/parsers/int_parser.dart';
import 'package:json_parser/src/parsers/list_parser.dart';
import 'package:json_parser/src/parsers/map_parser.dart';
import 'package:json_parser/src/parsers/nullable_bool_parser.dart';
import 'package:json_parser/src/parsers/nullable_double_parser.dart';
import 'package:json_parser/src/parsers/nullable_int_parser.dart';
import 'package:json_parser/src/parsers/nullable_list_parser.dart';
import 'package:json_parser/src/parsers/nullable_map_parser.dart';
import 'package:json_parser/src/parsers/nullable_num_parser.dart';
import 'package:json_parser/src/parsers/nullable_string_parser.dart';
import 'package:json_parser/src/parsers/num_parser.dart';
import 'package:json_parser/src/parsers/string_parser.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:parser_core/parser_core.dart';

class JsonParserRegistry extends ParserRegistry<Json> {
  JsonParserRegistry() : super();

  JsonParserRegistry.withKnownParsers() : super() {
    _registerPrimitiveTypes();
    _addMapParsers();
  }

  void _registerPrimitiveTypes() {
    _registerType(const BoolParser(), const NullableBoolParser());
    _registerType(const IntParser(), const NullableIntParser());
    _registerType(const DoubleParser(), const NullableDoubleParser());
    _registerType(const NumParser(), const NullableNumParser());
    _registerType(const StringParser(), const NullableStringParser());
  }

  void _registerType<T>(
    Parser<T, Json> parser,
    Parser<T?, Json> nullableParser,
  ) {
    addParser<T>(parser);
    addParser<T?>(nullableParser);
    _addListParsersFor(parser, nullableParser);
  }

  void _addListParsersFor<T>(
    Parser<T, Json> itemParser,
    Parser<T?, Json> nullableItemParser,
  ) {
    addParser<List<T>>(ListParser(itemParser));
    addParser<List<T?>>(ListParser(nullableItemParser));
    addParser<List<T>?>(NullableListParser(itemParser));
    addParser<List<T?>?>(NullableListParser(nullableItemParser));
  }

  void _addMapParsers() {
    _addMapParsersForKey(const StringParser());
  }

  void _addMapParsersForKey<K>(Parser<K, Json> keyParser) {
    _addMapParserCombination(
      keyParser,
      const BoolParser(),
      const NullableBoolParser(),
    );
    _addMapParserCombination(
      keyParser,
      const IntParser(),
      const NullableIntParser(),
    );
    _addMapParserCombination(
      keyParser,
      const DoubleParser(),
      const NullableDoubleParser(),
    );
    _addMapParserCombination(
      keyParser,
      const NumParser(),
      const NullableNumParser(),
    );
    _addMapParserCombination(
      keyParser,
      const StringParser(),
      const NullableStringParser(),
    );
  }

  void _addMapParserCombination<K, V>(
    Parser<K, Json> keyParser,
    Parser<V, Json> valueParser,
    Parser<V?, Json> nullableValueParser,
  ) {
    addParser<Map<K, V>>(
      MapParser(keyParser: keyParser, valueParser: valueParser),
    );
    addParser<Map<K, V?>>(
      MapParser(keyParser: keyParser, valueParser: nullableValueParser),
    );
    addParser<Map<K, V>?>(
      NullableMapParser(keyParser: keyParser, valueParser: valueParser),
    );
    addParser<Map<K, V?>?>(
      NullableMapParser(keyParser: keyParser, valueParser: nullableValueParser),
    );
  }
}
