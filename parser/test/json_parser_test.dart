// ignore_for_file: avoid_dynamic_calls

import 'package:parser/parser.dart';
import 'package:test/test.dart';

// Helper classes for testing

class Person {
  final String name;
  final int age;

  Person(this.name, this.age);

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
      };

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      json['name'] as String,
      json['age'] as int,
    );
  }
}

class BadPerson {
  final String name;

  BadPerson(this.name);

// No toJson() method
}

class WrongPerson {
  final String name;

  WrongPerson(this.name);

  // Wrong return type for toJson()
  List<dynamic> toJson() => [name];
}

class ThrowingPerson {
  final String name;

  ThrowingPerson(this.name);

  Map<String, dynamic> toJson() {
    throw Exception('Intentional error for testing');
  }
}

void main() {
  group('JsonParser', () {
    late JsonParser jsonParser;

    setUp(() {
      jsonParser = JsonParser();
    });

    group('encode', () {
      test('Should encode primitive types as-is', () {
        expect(jsonParser.encode(42), equals(42));
        expect(jsonParser.encode(3.14), equals(3.14));
        expect(jsonParser.encode('hello'), equals('hello'));
        expect(jsonParser.encode(true), equals(true));
      });

      test('Should encode List of primitive types as-is', () {
        expect(jsonParser.encode([1, 2, 3]), equals([1, 2, 3]));
        expect(jsonParser.encode(['a', 'b', 'c']), equals(['a', 'b', 'c']));
        expect(jsonParser.encode([true, false]), equals([true, false]));
      });

      test('Should encode Map with primitive types as-is', () {
        expect(
          jsonParser.encode({'a': 1, 'b': 2}),
          equals({'a': 1, 'b': 2}),
        );
      });

      test('Should encode custom type with toJson() method', () {
        final person = Person('John', 30);
        final encoded = jsonParser.encode(person);
        expect(encoded, isA<Map<String, dynamic>>());
        expect(encoded['name'], equals('John'));
        expect(encoded['age'], equals(30));
      });

      test('Should throw when encoding custom type without toJson()', () {
        final badPerson = BadPerson('John');
        expect(
          () => jsonParser.encode(badPerson),
          throwsA(isA<ParseException>()),
        );
      });

      test('Should throw when toJson() returns non-Map<String,dynamic>', () {
        final wrongPerson = WrongPerson('John');
        expect(
          () => jsonParser.encode(wrongPerson),
          throwsA(isA<ParseException>()),
        );
      });

      test('Should throw when encoding fails unexpectedly', () {
        final throwingPerson = ThrowingPerson('John');
        expect(
          () => jsonParser.encode(throwingPerson),
          throwsA(isA<ParseException>()),
        );
      });
    });

    group('decode', () {
      test('Should decode primitive types when types match', () {
        expect(jsonParser.decode<int>(42), equals(42));
        expect(jsonParser.decode<double>(3.14), equals(3.14));
        expect(jsonParser.decode<String>('hello'), equals('hello'));
        expect(jsonParser.decode<bool>(true), equals(true));
      });

      test("Should throw when primitive types don't match", () {
        expect(
          () => jsonParser.decode<int>('42'),
          throwsA(isA<ParseException>()),
        );
      });

      test('Should decode List of primitive types', () {
        expect(
          jsonParser.decode<List<int>>([1, 2, 3]),
          equals([1, 2, 3]),
        );
        expect(
          jsonParser.decode<List<String>>(['a', 'b']),
          equals(['a', 'b']),
        );
      });

      test('Should decode Map with primitive types', () {
        expect(
          jsonParser.decode<Map<String, int>>({'a': 1, 'b': 2}),
          equals({'a': 1, 'b': 2}),
        );
      });

      test('Should decode custom type when decoder is registered', () {
        jsonParser.addDecoder<Person>(Person.fromJson);
        final encoded = {'name': 'Alice', 'age': 25};
        final decoded = jsonParser.decode<Person>(encoded);
        expect(decoded, isA<Person>());
        expect(decoded.name, equals('Alice'));
        expect(decoded.age, equals(25));
      });

      test('Should throw when decoding custom type without registered decoder',
          () {
        final encoded = {'name': 'Alice', 'age': 25};
        expect(
          () => jsonParser.decode<Person>(encoded),
          throwsA(isA<ParseException>()),
        );
      });

      test('Should throw when decoding fails unexpectedly', () {
        jsonParser.addDecoder<Person>(Person.fromJson);
        final badData = {'name': 'Alice'}; // missing age
        expect(
          () => jsonParser.decode<Person>(badData),
          throwsA(isA<ParseException>()),
        );
      });

      test('Should throw when data type is not supported', () {
        expect(
          () => jsonParser.decode<int>({'a': 1}), // Map is not int
          throwsA(isA<ParseException>()),
        );
      });
    });
  });
}
