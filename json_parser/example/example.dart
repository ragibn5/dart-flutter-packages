// ignore_for_file: avoid_redundant_argument_values

import 'package:json_parser/src/parsers/bool_parser.dart';
import 'package:json_parser/src/parsers/double_parser.dart';
import 'package:json_parser/src/parsers/int_parser.dart';
import 'package:json_parser/src/parsers/list_parser.dart';
import 'package:json_parser/src/parsers/map_parser.dart';
import 'package:json_parser/src/parsers/nullable_int_parser.dart';
import 'package:json_parser/src/parsers/nullable_list_parser.dart';
import 'package:json_parser/src/parsers/nullable_map_parser.dart';
import 'package:json_parser/src/parsers/nullable_string_parser.dart';
import 'package:json_parser/src/parsers/string_parser.dart';
import 'package:json_parser/src/registry/json_parser_registry.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:parser/parser.dart';

class User {
  final int id;
  final String name;
  final String? nickname;

  User({required this.id, required this.name, this.nickname});

  @override
  String toString() => 'User{id: $id, name: $name, nickname: $nickname}';
}

class UserParser implements Parser<User, Json> {
  const UserParser();

  @override
  User decode(Json encoded) {
    final map = encoded! as JsonMap;

    return User(
      id: map['id']! as int,
      name: map['name']! as String,
      nickname: map['nickname'] as String?,
    );
  }

  @override
  Json encode(User value) => {
        'id': value.id,
        'name': value.name,
        'nickname': value.nickname,
      };
}

void main() {
  demoPrimitives();
  demoNullablePrimitives();
  demoNullableCollections();
  demoComplexNested();
  demoParserRegistry();
}

/// Primitives: bool, int, double, String — non-nullable.
void demoPrimitives() {
  print(const BoolParser().decode(const BoolParser().encode(true)));
  print(const IntParser().decode(const IntParser().encode(42)));
  print(const DoubleParser().decode(const DoubleParser().encode(3.14)));
  print(const StringParser().decode(const StringParser().encode('hello')));
}

/// Nullable primitives and nullable list/map wrappers.
void demoNullablePrimitives() {
  // int? — null round-trip
  const intParser = NullableIntParser();
  print(intParser.decode(intParser.encode(null))); // null
  print(intParser.decode(intParser.encode(7))); // 7

  // String? — null round-trip
  const stringParser = NullableStringParser();
  print(stringParser.decode(stringParser.encode(null))); // null
  print(stringParser.decode(stringParser.encode('hi'))); // hi
}

/// Nullable collections: List<T?>?, Map<K, V?>?.
void demoNullableCollections() {
  // List<int?>  — list present, some items null
  const listParser = ListParser(NullableIntParser());
  final list = [1, null, 3];
  print(listParser.decode(listParser.encode(list))); // [1, null, 3]

  // List<int>?  — list itself may be null
  const nullableListParser = NullableListParser(IntParser());
  print(nullableListParser.decode(nullableListParser.encode(null))); // null
  print(nullableListParser.decode(nullableListParser.encode([1, 2]))); // [1, 2]

  // Map<String, int?>  — values may be null
  const mapParser = MapParser(
    keyParser: StringParser(),
    valueParser: NullableIntParser(),
  );
  final map = {'a': 1, 'b': null, 'c': 3};
  print(mapParser.decode(mapParser.encode(map))); // {a: 1, b: null, c: 3}

  // Map<String, int>?  — map itself may be null
  const nullableMapParser = NullableMapParser(
    keyParser: StringParser(),
    valueParser: IntParser(),
  );
  print(nullableMapParser.decode(nullableMapParser.encode(null))); // null
  print(nullableMapParser.decode(nullableMapParser.encode({'x': 9}))); // {x: 9}
}

/// Complex nested: List<Map<String, List<User?>>>.
/// Demonstrates composing parsers arbitrarily, including nullable item lists.
void demoComplexNested() {
  const complexParser = ListParser(
    MapParser(
      keyParser: StringParser(),
      valueParser: ListParser(UserParser()),
    ),
  );

  final data = [
    {
      'admins': [User(id: 1, name: 'John', nickname: 'jj')],
      'guests': [User(id: 2, name: 'Alice', nickname: null)],
    },
  ];

  final encoded = complexParser.encode(data);
  final decoded = complexParser.decode(encoded);

  print('Encoded: $encoded');
  print('Decoded: $decoded');
}

/// Registry: custom parsers registered alongside built-ins,
/// including nullable User variant.
void demoParserRegistry() {
  const userParser = UserParser();

  final registry = JsonParserRegistry.withKnownParsers()..addParser(userParser);

  final user = User(id: 1, name: 'John', nickname: null);

  // Encode/decode via registry lookup
  final encoded = registry.getParser<User>()?.encode(user);
  final decoded = registry.getParser<User>()?.decode(encoded);
  print('Registry User: $decoded');

  // Built-in nullable list from registry
  final scores = [10, null, 30];
  final encodedScores = registry.getParser<List<int?>>()?.encode(scores);
  final decodedScores = registry.getParser<List<int?>>()?.decode(encodedScores);
  print('Registry List<int?>: $decodedScores');

  // getRuntimeParser for dynamic dispatch
  final animals = [user];
  final encodedAnimals = animals
      .map((a) => registry.getRuntimeParser(a.runtimeType)?.encode(a))
      .toList();
  print('Runtime dispatch: $encodedAnimals');
}
