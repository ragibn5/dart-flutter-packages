import 'package:json_parser/src/parsers/bool_parser.dart';
import 'package:json_parser/src/parsers/double_parser.dart';
import 'package:json_parser/src/parsers/int_parser.dart';
import 'package:json_parser/src/parsers/nullable_bool_parser.dart';
import 'package:json_parser/src/parsers/nullable_double_parser.dart';
import 'package:json_parser/src/parsers/nullable_int_parser.dart';
import 'package:json_parser/src/parsers/nullable_num_parser.dart';
import 'package:json_parser/src/parsers/nullable_string_parser.dart';
import 'package:json_parser/src/parsers/num_parser.dart';
import 'package:json_parser/src/parsers/string_parser.dart';
import 'package:json_parser/src/registry/json_parser_registry.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:test/test.dart';

void main() {
  Set<Type> expectedKnownTypes() {
    final expected = <Type>{};

    void collect<T>(Set<Type> types) {
      types.add(T);
    }

    void collectPrimitive<T>(Set<Type> types) {
      collect<T>(types);
      collect<T?>(types);
      collect<List<T>>(types);
      collect<List<T?>>(types);
      collect<List<T>?>(types);
      collect<List<T?>?>(types);
    }

    void collectMap<K, V>(Set<Type> types) {
      collect<Map<K, V>>(types);
      collect<Map<K, V?>>(types);
      collect<Map<K, V>?>(types);
      collect<Map<K, V?>?>(types);
    }

    void collectMapKeys<K>(Set<Type> types) {
      collectMap<K, bool>(types);
      collectMap<K, int>(types);
      collectMap<K, double>(types);
      collectMap<K, num>(types);
      collectMap<K, String>(types);
    }

    collectPrimitive<bool>(expected);
    collectPrimitive<int>(expected);
    collectPrimitive<double>(expected);
    collectPrimitive<num>(expected);
    collectPrimitive<String>(expected);

    collectMapKeys<String>(expected);
    collectMapKeys<bool>(expected);
    collectMapKeys<int>(expected);
    collectMapKeys<double>(expected);

    return expected;
  }

  void expectRoundTrip<T extends Object?>(
    JsonParserRegistry registry,
    Json encoded,
    T expected,
  ) {
    final parser = registry.getParser<T>();
    expect(parser, isNotNull, reason: 'No parser registered for $T');
    final decoded = parser!.decode(encoded);
    expect(
      decoded,
      equals(expected),
      reason: 'decode($encoded) mismatch for $T',
    );
    expect(
      parser.encode(decoded),
      equals(encoded),
      reason: 'encode($decoded) mismatch for $T',
    );
  }

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

    final knownTypes = expectedKnownTypes();

    test('registers the expected total number of parsers', () {
      // 5 primitives
      // 5 nullable primitives
      // 20 list types (5 item types × 4 list shapes)
      // 80 map types  (4 key types × 5 value types × 4 map shapes)
      // = 110
      expect(registry.parserMap, hasLength(knownTypes.length));
    });

    test('registers every combination of known parser types', () {
      expect(registry.parserMap.keys.toSet(), knownTypes);
    });

    group('registers a parser for every known type', () {
      for (final type in knownTypes) {
        test('$type', () {
          expect(registry.getRuntimeParser(type), isNotNull);
        });
      }
    });

    group('registers the expected parser classes', () {
      test('BoolParser for bool', () {
        expect(registry.getParser<bool>(), isA<BoolParser>());
      });

      test('IntParser for int', () {
        expect(registry.getParser<int>(), isA<IntParser>());
      });

      test('DoubleParser for double', () {
        expect(registry.getParser<double>(), isA<DoubleParser>());
      });

      test('NumParser for num', () {
        expect(registry.getParser<num>(), isA<NumParser>());
      });

      test('StringParser for String', () {
        expect(registry.getParser<String>(), isA<StringParser>());
      });

      test('NullableBoolParser for bool?', () {
        expect(registry.getParser<bool?>(), isA<NullableBoolParser>());
      });

      test('NullableIntParser for int?', () {
        expect(registry.getParser<int?>(), isA<NullableIntParser>());
      });

      test('NullableDoubleParser for double?', () {
        expect(registry.getParser<double?>(), isA<NullableDoubleParser>());
      });

      test('NullableNumParser for num?', () {
        expect(registry.getParser<num?>(), isA<NullableNumParser>());
      });

      test('NullableStringParser for String?', () {
        expect(registry.getParser<String?>(), isA<NullableStringParser>());
      });
    });

    group('round-trips values through the registered parsers', () {
      test('primitive types', () {
        void checkPrimitive<T extends Object?>(T value) {
          expectRoundTrip(registry, value, value);
        }

        checkPrimitive<bool>(true);
        checkPrimitive<int>(42);
        checkPrimitive<double>(3.5);
        checkPrimitive<num>(42);
        checkPrimitive<num>(3.5);
        checkPrimitive<String>('hi');
      });

      test('list types', () {
        void checkListShapes<T extends Object?>(T value) {
          expectRoundTrip<List<T>>(registry, [value, value], [value, value]);
          expectRoundTrip<List<T?>>(
            registry,
            [value, null],
            [value, null],
          );
          expectRoundTrip<List<T>?>(
            registry,
            [value, value],
            [value, value],
          );
          expectRoundTrip<List<T>?>(registry, null, null);
          expectRoundTrip<List<T?>?>(
            registry,
            [value, null],
            [value, null],
          );
          expectRoundTrip<List<T?>?>(registry, null, null);
        }

        checkListShapes<bool>(true);
        checkListShapes<int>(42);
        checkListShapes<double>(3.5);
        checkListShapes<num>(42);
        checkListShapes<String>('hi');
      });

      test('map types', () {
        void checkMapShapes<K extends Object?, V extends Object?>(
          K key1,
          K key2,
          V value,
        ) {
          expectRoundTrip<Map<K, V>>(
            registry,
            {key1: value, key2: value},
            {key1: value, key2: value},
          );
          expectRoundTrip<Map<K, V?>>(
            registry,
            {key1: value, key2: null},
            {key1: value, key2: null},
          );
          expectRoundTrip<Map<K, V>?>(
            registry,
            {key1: value, key2: value},
            {key1: value, key2: value},
          );
          expectRoundTrip<Map<K, V>?>(registry, null, null);
          expectRoundTrip<Map<K, V?>?>(
            registry,
            {key1: value, key2: null},
            {key1: value, key2: null},
          );
          expectRoundTrip<Map<K, V?>?>(registry, null, null);
        }

        checkMapShapes<String, bool>('a', 'b', true);
        checkMapShapes<String, int>('a', 'b', 42);
        checkMapShapes<String, double>('a', 'b', 3.5);
        checkMapShapes<String, num>('a', 'b', 42);
        checkMapShapes<String, String>('a', 'b', 'hi');

        checkMapShapes<bool, bool>(true, false, true);
        checkMapShapes<bool, int>(true, false, 42);
        checkMapShapes<bool, double>(true, false, 3.5);
        checkMapShapes<bool, num>(true, false, 42);
        checkMapShapes<bool, String>(true, false, 'hi');

        checkMapShapes<int, bool>(1, 2, true);
        checkMapShapes<int, int>(1, 2, 42);
        checkMapShapes<int, double>(1, 2, 3.5);
        checkMapShapes<int, num>(1, 2, 42);
        checkMapShapes<int, String>(1, 2, 'hi');

        checkMapShapes<double, bool>(1, 2, true);
        checkMapShapes<double, int>(1, 2, 42);
        checkMapShapes<double, double>(1, 2, 3.5);
        checkMapShapes<double, num>(1, 2, 42);
        checkMapShapes<double, String>(1, 2, 'hi');
      });
    });
  });
}
