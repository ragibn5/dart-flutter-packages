import 'package:json_parser/json_parser.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parser/parser.dart';
import 'package:test/test.dart';

class _MockKeyParser extends Mock implements Parser<String, Json> {}

class _MockValueParser extends Mock implements Parser<int, Json> {}

void main() {
  late _MockKeyParser mockKeyParser;
  late _MockValueParser mockValueParser;
  late MapParser<String, int> sut;

  setUp(() {
    mockKeyParser = _MockKeyParser();
    mockValueParser = _MockValueParser();
    sut = MapParser(
      keyParser: mockKeyParser,
      valueParser: mockValueParser,
    );
  });

  test('decode() should throw if passed value is not a Map', () {
    final invalidInputs = ['string', 123, 1.23, <dynamic>[], true, null];
    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() should call key and value parser for each entry', () {
    final entries = {'a': 1, 'b': 2, 'c': 3};

    when(() => mockKeyParser.decode(any()))
        .thenAnswer((i) => 'parsed_${i.positionalArguments.first}');
    when(() => mockValueParser.decode(any()))
        .thenAnswer((i) => (i.positionalArguments.first as int) * 10);

    sut.decode(entries);

    verify(() => mockKeyParser.decode(any())).called(entries.length);
    verify(() => mockValueParser.decode(any())).called(entries.length);
  });

  test('decode() should handle empty map', () {
    final entries = <String, int>{};
    final result = sut.decode(entries);
    expect(result, isEmpty);
    verifyNever(() => mockKeyParser.decode(any()));
    verifyNever(() => mockValueParser.decode(any()));
  });

  test('encode() should call key and value parser for each entry', () {
    final entries = {'a': 1, 'b': 2, 'c': 3};

    when(() => mockKeyParser.encode(any()))
        .thenAnswer((i) => 'encoded_${i.positionalArguments.first}');
    when(() => mockValueParser.encode(any()))
        .thenAnswer((i) => (i.positionalArguments.first as int) * 10);

    sut.encode(entries);

    verify(() => mockKeyParser.encode(any())).called(entries.length);
    verify(() => mockValueParser.encode(any())).called(entries.length);
  });

  test('encode() should handle empty map', () {
    final entries = <String, int>{};
    final result = sut.encode(entries);
    expect(result, isEmpty);
    verifyNever(() => mockKeyParser.encode(any()));
    verifyNever(() => mockValueParser.encode(any()));
  });

  test('round-trip encode → decode → encode preserves map structure', () {
    final entries = {'a': 1, 'b': 2};

    when(() => mockKeyParser.encode(any()))
        .thenAnswer((i) => i.positionalArguments.first as String);
    when(() => mockValueParser.encode(any()))
        .thenAnswer((i) => i.positionalArguments.first as int);
    when(() => mockKeyParser.decode(any()))
        .thenAnswer((i) => i.positionalArguments.first as String);
    when(() => mockValueParser.decode(any()))
        .thenAnswer((i) => i.positionalArguments.first as int);

    final encoded = sut.encode(entries);
    final decoded = sut.decode(encoded);
    final reEncoded = sut.encode(decoded);

    expect(decoded, entries);
    expect(reEncoded, entries);
  });
}
