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
import 'package:json_parser/src/parsers/nullable_string_parser.dart';
import 'package:json_parser/src/parsers/string_parser.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:parser/parser.dart';

class JsonParserRegistry extends ParserRegistry<Json> {
  JsonParserRegistry() : super();

  JsonParserRegistry.withKnownParsers() : super() {
    _addPrimitiveParsers();
    _addNullablePrimitiveParsers();
    _addListParsers();
    _addNullableItemListParsers();
    _addNullableListParsers();
    _addNullableItemNullableListParsers();
    _addMapParsers();
    _addNullableValueMapParsers();
    _addNullableMapParsers();
    _addNullableValueNullableMapParsers();
  }

  void _addPrimitiveParsers() {
    addParser(const BoolParser());
    addParser(const IntParser());
    addParser(const DoubleParser());
    addParser(const StringParser());
  }

  void _addNullablePrimitiveParsers() {
    addParser(const NullableBoolParser());
    addParser(const NullableIntParser());
    addParser(const NullableDoubleParser());
    addParser(const NullableStringParser());
  }

  void _addListParsers() {
    addParser(const ListParser(BoolParser()));
    addParser(const ListParser(IntParser()));
    addParser(const ListParser(DoubleParser()));
    addParser(const ListParser(StringParser()));
  }

  void _addNullableItemListParsers() {
    addParser(const ListParser(NullableBoolParser()));
    addParser(const ListParser(NullableIntParser()));
    addParser(const ListParser(NullableDoubleParser()));
    addParser(const ListParser(NullableStringParser()));
  }

  void _addNullableListParsers() {
    addParser(const NullableListParser(BoolParser()));
    addParser(const NullableListParser(IntParser()));
    addParser(const NullableListParser(DoubleParser()));
    addParser(const NullableListParser(StringParser()));
  }

  void _addNullableItemNullableListParsers() {
    addParser(const NullableListParser(NullableBoolParser()));
    addParser(const NullableListParser(NullableIntParser()));
    addParser(const NullableListParser(NullableDoubleParser()));
    addParser(const NullableListParser(NullableStringParser()));
  }

  void _addMapParsers() {
    // Key = String
    addParser(
      const MapParser(keyParser: StringParser(), valueParser: BoolParser()),
    );
    addParser(
      const MapParser(keyParser: StringParser(), valueParser: IntParser()),
    );
    addParser(
      const MapParser(keyParser: StringParser(), valueParser: DoubleParser()),
    );
    addParser(
      const MapParser(keyParser: StringParser(), valueParser: StringParser()),
    );

    // Key = Bool
    addParser(
      const MapParser(keyParser: BoolParser(), valueParser: BoolParser()),
    );
    addParser(
      const MapParser(keyParser: BoolParser(), valueParser: IntParser()),
    );
    addParser(
      const MapParser(keyParser: BoolParser(), valueParser: DoubleParser()),
    );
    addParser(
      const MapParser(keyParser: BoolParser(), valueParser: StringParser()),
    );

    // Key = Int
    addParser(
      const MapParser(keyParser: IntParser(), valueParser: BoolParser()),
    );
    addParser(
      const MapParser(keyParser: IntParser(), valueParser: IntParser()),
    );
    addParser(
      const MapParser(keyParser: IntParser(), valueParser: DoubleParser()),
    );
    addParser(
      const MapParser(keyParser: IntParser(), valueParser: StringParser()),
    );

    // Key = Double
    addParser(
      const MapParser(keyParser: DoubleParser(), valueParser: BoolParser()),
    );
    addParser(
      const MapParser(keyParser: DoubleParser(), valueParser: IntParser()),
    );
    addParser(
      const MapParser(keyParser: DoubleParser(), valueParser: DoubleParser()),
    );
    addParser(
      const MapParser(keyParser: DoubleParser(), valueParser: StringParser()),
    );
  }

  void _addNullableValueMapParsers() {
    // Key = String
    addParser(
      const MapParser(
        keyParser: StringParser(),
        valueParser: NullableBoolParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: StringParser(),
        valueParser: NullableIntParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: StringParser(),
        valueParser: NullableDoubleParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: StringParser(),
        valueParser: NullableStringParser(),
      ),
    );

    // Key = Bool
    addParser(
      const MapParser(
        keyParser: BoolParser(),
        valueParser: NullableBoolParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: BoolParser(),
        valueParser: NullableIntParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: BoolParser(),
        valueParser: NullableDoubleParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: BoolParser(),
        valueParser: NullableStringParser(),
      ),
    );

    // Key = Int
    addParser(
      const MapParser(
        keyParser: IntParser(),
        valueParser: NullableBoolParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: IntParser(),
        valueParser: NullableIntParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: IntParser(),
        valueParser: NullableDoubleParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: IntParser(),
        valueParser: NullableStringParser(),
      ),
    );

    // Key = Double
    addParser(
      const MapParser(
        keyParser: DoubleParser(),
        valueParser: NullableBoolParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: DoubleParser(),
        valueParser: NullableIntParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: DoubleParser(),
        valueParser: NullableDoubleParser(),
      ),
    );
    addParser(
      const MapParser(
        keyParser: DoubleParser(),
        valueParser: NullableStringParser(),
      ),
    );
  }

  void _addNullableMapParsers() {
    // Key = String
    addParser(
      const NullableMapParser(
        keyParser: StringParser(),
        valueParser: BoolParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: StringParser(),
        valueParser: IntParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: StringParser(),
        valueParser: DoubleParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: StringParser(),
        valueParser: StringParser(),
      ),
    );

    // Key = Bool
    addParser(
      const NullableMapParser(
        keyParser: BoolParser(),
        valueParser: BoolParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: BoolParser(),
        valueParser: IntParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: BoolParser(),
        valueParser: DoubleParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: BoolParser(),
        valueParser: StringParser(),
      ),
    );

    // Key = Int
    addParser(
      const NullableMapParser(
        keyParser: IntParser(),
        valueParser: BoolParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: IntParser(),
        valueParser: IntParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: IntParser(),
        valueParser: DoubleParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: IntParser(),
        valueParser: StringParser(),
      ),
    );

    // Key = Double
    addParser(
      const NullableMapParser(
        keyParser: DoubleParser(),
        valueParser: BoolParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: DoubleParser(),
        valueParser: IntParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: DoubleParser(),
        valueParser: DoubleParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: DoubleParser(),
        valueParser: StringParser(),
      ),
    );
  }

  void _addNullableValueNullableMapParsers() {
    // Key = String
    addParser(
      const NullableMapParser(
        keyParser: StringParser(),
        valueParser: NullableBoolParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: StringParser(),
        valueParser: NullableIntParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: StringParser(),
        valueParser: NullableDoubleParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: StringParser(),
        valueParser: NullableStringParser(),
      ),
    );

    // Key = Bool
    addParser(
      const NullableMapParser(
        keyParser: BoolParser(),
        valueParser: NullableBoolParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: BoolParser(),
        valueParser: NullableIntParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: BoolParser(),
        valueParser: NullableDoubleParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: BoolParser(),
        valueParser: NullableStringParser(),
      ),
    );

    // Key = Int
    addParser(
      const NullableMapParser(
        keyParser: IntParser(),
        valueParser: NullableBoolParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: IntParser(),
        valueParser: NullableIntParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: IntParser(),
        valueParser: NullableDoubleParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: IntParser(),
        valueParser: NullableStringParser(),
      ),
    );

    // Key = Double
    addParser(
      const NullableMapParser(
        keyParser: DoubleParser(),
        valueParser: NullableBoolParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: DoubleParser(),
        valueParser: NullableIntParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: DoubleParser(),
        valueParser: NullableDoubleParser(),
      ),
    );
    addParser(
      const NullableMapParser(
        keyParser: DoubleParser(),
        valueParser: NullableStringParser(),
      ),
    );
  }
}
