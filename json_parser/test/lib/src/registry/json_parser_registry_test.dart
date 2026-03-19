import 'package:json_parser/src/parsers/bool_parser.dart';
import 'package:json_parser/src/parsers/double_parser.dart';
import 'package:json_parser/src/parsers/int_parser.dart';
import 'package:json_parser/src/parsers/nullable_bool_parser.dart';
import 'package:json_parser/src/parsers/nullable_double_parser.dart';
import 'package:json_parser/src/parsers/nullable_int_parser.dart';
import 'package:json_parser/src/parsers/nullable_string_parser.dart';
import 'package:json_parser/src/parsers/string_parser.dart';
import 'package:json_parser/src/registry/json_parser_registry.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParserRegistry', () {
    group('default constructor', () {
      test('registers no parsers', () {
        final registry = JsonParserRegistry();
        expect(registry.parserMap, isEmpty);
      });
    });

    group('withKnownParsers constructor', () {
      late JsonParserRegistry registry;

      setUp(() {
        registry = JsonParserRegistry.withKnownParsers();
      });

      test('registers the expected total number of parsers', () {
        // 4 primitives
        // 4 nullable primitives
        // 8 list types   (4 item types × List / NullableList)
        // 8 list types   (4 nullable item types × List / NullableList)
        // 32 map types   (4 keys × 4 values × Map / NullableMap)
        // 32 map types   (4 keys × 4 nullable values × Map / NullableMap)
        // = 88
        expect(registry.parserMap, hasLength(88));
      });

      group('primitives', () {
        test('registers BoolParser for bool', () {
          expect(registry.getParser<bool>(), isA<BoolParser>());
        });

        test('registers IntParser for int', () {
          expect(registry.getParser<int>(), isA<IntParser>());
        });

        test('registers DoubleParser for double', () {
          expect(registry.getParser<double>(), isA<DoubleParser>());
        });

        test('registers StringParser for String', () {
          expect(registry.getParser<String>(), isA<StringParser>());
        });
      });

      group('nullable primitives', () {
        test('registers NullableBoolParser for bool?', () {
          expect(registry.getParser<bool?>(), isA<NullableBoolParser>());
        });

        test('registers NullableIntParser for int?', () {
          expect(registry.getParser<int?>(), isA<NullableIntParser>());
        });

        test('registers NullableDoubleParser for double?', () {
          expect(registry.getParser<double?>(), isA<NullableDoubleParser>());
        });

        test('registers NullableStringParser for String?', () {
          expect(registry.getParser<String?>(), isA<NullableStringParser>());
        });
      });

      group('List<T>', () {
        test('registers parser for List<bool>', () {
          expect(registry.getParser<List<bool>>(), isNotNull);
        });

        test('registers parser for List<int>', () {
          expect(registry.getParser<List<int>>(), isNotNull);
        });

        test('registers parser for List<double>', () {
          expect(registry.getParser<List<double>>(), isNotNull);
        });

        test('registers parser for List<String>', () {
          expect(registry.getParser<List<String>>(), isNotNull);
        });
      });

      group('List<T?>', () {
        test('registers parser for List<bool?>', () {
          expect(registry.getParser<List<bool?>>(), isNotNull);
        });

        test('registers parser for List<int?>', () {
          expect(registry.getParser<List<int?>>(), isNotNull);
        });

        test('registers parser for List<double?>', () {
          expect(registry.getParser<List<double?>>(), isNotNull);
        });

        test('registers parser for List<String?>', () {
          expect(registry.getParser<List<String?>>(), isNotNull);
        });
      });

      group('List<T>?', () {
        test('registers parser for List<bool>?', () {
          expect(registry.getParser<List<bool>?>(), isNotNull);
        });

        test('registers parser for List<int>?', () {
          expect(registry.getParser<List<int>?>(), isNotNull);
        });

        test('registers parser for List<double>?', () {
          expect(registry.getParser<List<double>?>(), isNotNull);
        });

        test('registers parser for List<String>?', () {
          expect(registry.getParser<List<String>?>(), isNotNull);
        });
      });

      group('List<T?>?', () {
        test('registers parser for List<bool?>?', () {
          expect(registry.getParser<List<bool?>?>(), isNotNull);
        });

        test('registers parser for List<int?>?', () {
          expect(registry.getParser<List<int?>?>(), isNotNull);
        });

        test('registers parser for List<double?>?', () {
          expect(registry.getParser<List<double?>?>(), isNotNull);
        });

        test('registers parser for List<String?>?', () {
          expect(registry.getParser<List<String?>?>(), isNotNull);
        });
      });

      group('Map<K, V>', () {
        test('registers parser for Map<String, bool>', () {
          expect(registry.getParser<Map<String, bool>>(), isNotNull);
        });

        test('registers parser for Map<String, int>', () {
          expect(registry.getParser<Map<String, int>>(), isNotNull);
        });

        test('registers parser for Map<String, double>', () {
          expect(registry.getParser<Map<String, double>>(), isNotNull);
        });

        test('registers parser for Map<String, String>', () {
          expect(registry.getParser<Map<String, String>>(), isNotNull);
        });

        test('registers parser for Map<bool, bool>', () {
          expect(registry.getParser<Map<bool, bool>>(), isNotNull);
        });

        test('registers parser for Map<bool, int>', () {
          expect(registry.getParser<Map<bool, int>>(), isNotNull);
        });

        test('registers parser for Map<bool, double>', () {
          expect(registry.getParser<Map<bool, double>>(), isNotNull);
        });

        test('registers parser for Map<bool, String>', () {
          expect(registry.getParser<Map<bool, String>>(), isNotNull);
        });

        test('registers parser for Map<int, bool>', () {
          expect(registry.getParser<Map<int, bool>>(), isNotNull);
        });

        test('registers parser for Map<int, int>', () {
          expect(registry.getParser<Map<int, int>>(), isNotNull);
        });

        test('registers parser for Map<int, double>', () {
          expect(registry.getParser<Map<int, double>>(), isNotNull);
        });

        test('registers parser for Map<int, String>', () {
          expect(registry.getParser<Map<int, String>>(), isNotNull);
        });

        test('registers parser for Map<double, bool>', () {
          expect(registry.getParser<Map<double, bool>>(), isNotNull);
        });

        test('registers parser for Map<double, int>', () {
          expect(registry.getParser<Map<double, int>>(), isNotNull);
        });

        test('registers parser for Map<double, double>', () {
          expect(registry.getParser<Map<double, double>>(), isNotNull);
        });

        test('registers parser for Map<double, String>', () {
          expect(registry.getParser<Map<double, String>>(), isNotNull);
        });
      });

      group('Map<K, V?>', () {
        test('registers parser for Map<String, bool?>', () {
          expect(registry.getParser<Map<String, bool?>>(), isNotNull);
        });

        test('registers parser for Map<String, int?>', () {
          expect(registry.getParser<Map<String, int?>>(), isNotNull);
        });

        test('registers parser for Map<String, double?>', () {
          expect(registry.getParser<Map<String, double?>>(), isNotNull);
        });

        test('registers parser for Map<String, String?>', () {
          expect(registry.getParser<Map<String, String?>>(), isNotNull);
        });

        test('registers parser for Map<bool, bool?>', () {
          expect(registry.getParser<Map<bool, bool?>>(), isNotNull);
        });

        test('registers parser for Map<bool, int?>', () {
          expect(registry.getParser<Map<bool, int?>>(), isNotNull);
        });

        test('registers parser for Map<bool, double?>', () {
          expect(registry.getParser<Map<bool, double?>>(), isNotNull);
        });

        test('registers parser for Map<bool, String?>', () {
          expect(registry.getParser<Map<bool, String?>>(), isNotNull);
        });

        test('registers parser for Map<int, bool?>', () {
          expect(registry.getParser<Map<int, bool?>>(), isNotNull);
        });

        test('registers parser for Map<int, int?>', () {
          expect(registry.getParser<Map<int, int?>>(), isNotNull);
        });

        test('registers parser for Map<int, double?>', () {
          expect(registry.getParser<Map<int, double?>>(), isNotNull);
        });

        test('registers parser for Map<int, String?>', () {
          expect(registry.getParser<Map<int, String?>>(), isNotNull);
        });

        test('registers parser for Map<double, bool?>', () {
          expect(registry.getParser<Map<double, bool?>>(), isNotNull);
        });

        test('registers parser for Map<double, int?>', () {
          expect(registry.getParser<Map<double, int?>>(), isNotNull);
        });

        test('registers parser for Map<double, double?>', () {
          expect(registry.getParser<Map<double, double?>>(), isNotNull);
        });

        test('registers parser for Map<double, String?>', () {
          expect(registry.getParser<Map<double, String?>>(), isNotNull);
        });
      });

      group('Map<K, V>?', () {
        test('registers parser for Map<String, bool>?', () {
          expect(registry.getParser<Map<String, bool>?>(), isNotNull);
        });

        test('registers parser for Map<String, int>?', () {
          expect(registry.getParser<Map<String, int>?>(), isNotNull);
        });

        test('registers parser for Map<String, double>?', () {
          expect(registry.getParser<Map<String, double>?>(), isNotNull);
        });

        test('registers parser for Map<String, String>?', () {
          expect(registry.getParser<Map<String, String>?>(), isNotNull);
        });

        test('registers parser for Map<bool, bool>?', () {
          expect(registry.getParser<Map<bool, bool>?>(), isNotNull);
        });

        test('registers parser for Map<bool, int>?', () {
          expect(registry.getParser<Map<bool, int>?>(), isNotNull);
        });

        test('registers parser for Map<bool, double>?', () {
          expect(registry.getParser<Map<bool, double>?>(), isNotNull);
        });

        test('registers parser for Map<bool, String>?', () {
          expect(registry.getParser<Map<bool, String>?>(), isNotNull);
        });

        test('registers parser for Map<int, bool>?', () {
          expect(registry.getParser<Map<int, bool>?>(), isNotNull);
        });

        test('registers parser for Map<int, int>?', () {
          expect(registry.getParser<Map<int, int>?>(), isNotNull);
        });

        test('registers parser for Map<int, double>?', () {
          expect(registry.getParser<Map<int, double>?>(), isNotNull);
        });

        test('registers parser for Map<int, String>?', () {
          expect(registry.getParser<Map<int, String>?>(), isNotNull);
        });

        test('registers parser for Map<double, bool>?', () {
          expect(registry.getParser<Map<double, bool>?>(), isNotNull);
        });

        test('registers parser for Map<double, int>?', () {
          expect(registry.getParser<Map<double, int>?>(), isNotNull);
        });

        test('registers parser for Map<double, double>?', () {
          expect(registry.getParser<Map<double, double>?>(), isNotNull);
        });

        test('registers parser for Map<double, String>?', () {
          expect(registry.getParser<Map<double, String>?>(), isNotNull);
        });
      });

      group('Map<K, V?>?', () {
        test('registers parser for Map<String, bool?>?', () {
          expect(registry.getParser<Map<String, bool?>?>(), isNotNull);
        });

        test('registers parser for Map<String, int?>?', () {
          expect(registry.getParser<Map<String, int?>?>(), isNotNull);
        });

        test('registers parser for Map<String, double?>?', () {
          expect(registry.getParser<Map<String, double?>?>(), isNotNull);
        });

        test('registers parser for Map<String, String?>?', () {
          expect(registry.getParser<Map<String, String?>?>(), isNotNull);
        });

        test('registers parser for Map<bool, bool?>?', () {
          expect(registry.getParser<Map<bool, bool?>?>(), isNotNull);
        });

        test('registers parser for Map<bool, int?>?', () {
          expect(registry.getParser<Map<bool, int?>?>(), isNotNull);
        });

        test('registers parser for Map<bool, double?>?', () {
          expect(registry.getParser<Map<bool, double?>?>(), isNotNull);
        });

        test('registers parser for Map<bool, String?>?', () {
          expect(registry.getParser<Map<bool, String?>?>(), isNotNull);
        });

        test('registers parser for Map<int, bool?>?', () {
          expect(registry.getParser<Map<int, bool?>?>(), isNotNull);
        });

        test('registers parser for Map<int, int?>?', () {
          expect(registry.getParser<Map<int, int?>?>(), isNotNull);
        });

        test('registers parser for Map<int, double?>?', () {
          expect(registry.getParser<Map<int, double?>?>(), isNotNull);
        });

        test('registers parser for Map<int, String?>?', () {
          expect(registry.getParser<Map<int, String?>?>(), isNotNull);
        });

        test('registers parser for Map<double, bool?>?', () {
          expect(registry.getParser<Map<double, bool?>?>(), isNotNull);
        });

        test('registers parser for Map<double, int?>?', () {
          expect(registry.getParser<Map<double, int?>?>(), isNotNull);
        });

        test('registers parser for Map<double, double?>?', () {
          expect(registry.getParser<Map<double, double?>?>(), isNotNull);
        });

        test('registers parser for Map<double, String?>?', () {
          expect(registry.getParser<Map<double, String?>?>(), isNotNull);
        });
      });
    });
  });
}
