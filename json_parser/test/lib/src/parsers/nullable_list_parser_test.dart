import 'package:json_parser/src/parsers/nullable_list_parser.dart';
import 'package:json_parser/src/types/json_types.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parser/parser.dart';
import 'package:test/test.dart';

class _MockItemParser extends Mock implements Parser<int, Json> {}

void main() {
  late _MockItemParser mockItemParser;
  late NullableListParser<int> sut;

  setUp(() {
    mockItemParser = _MockItemParser();
    sut = NullableListParser(mockItemParser);
  });

  test('decode() should throw if passed any non-list value', () {
    final invalidInputs = [123, 'string', true, <dynamic>{}, 1.23];
    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() should return null if passed null', () {
    expect(sut.decode(null), isNull);
  });

  test('decode() should call item parser for each element when not null', () {
    final items = [1, 2, 3];

    when(() => mockItemParser.decode(any())).thenAnswer(
      (invocation) => (invocation.positionalArguments.first as int) * 10,
    );

    final result = sut.decode(items);

    verify(() => mockItemParser.decode(any())).called(items.length);
    expect(result, [10, 20, 30]);
  });

  test('decode() should correctly handle single-element list', () {
    final items = [42];

    when(() => mockItemParser.decode(42)).thenReturn(99);

    final result = sut.decode(items);

    expect(result, [99]);
    verify(() => mockItemParser.decode(42)).called(1);
  });

  test('decode() should return empty list when given empty list', () {
    final items = <int>[];

    final result = sut.decode(items);

    expect(result, isEmpty);
    verifyNever(() => mockItemParser.decode(any()));
  });

  test('encode() should return null when given null', () {
    expect(sut.encode(null), isNull);
  });

  test('encode() should call item parser for each element when not null', () {
    final items = [1, 2, 3];

    when(() => mockItemParser.encode(any())).thenAnswer(
      (invocation) => (invocation.positionalArguments.first as int) * 10,
    );

    final result = sut.encode(items);

    verify(() => mockItemParser.encode(any())).called(items.length);
    expect(result, [10, 20, 30]);
  });

  test('encode() should correctly handle single-element list', () {
    final items = [42];

    when(() => mockItemParser.encode(42)).thenReturn(99);

    final result = sut.encode(items);

    expect(result, [99]);
    verify(() => mockItemParser.encode(42)).called(1);
  });

  test('encode() should return empty list when given empty list', () {
    final items = <int>[];

    final result = sut.encode(items);

    expect(result, isEmpty);
    verifyNever(() => mockItemParser.encode(any()));
  });

  test('round-trip encode → decode → encode preserves values', () {
    final items = [1, 2, 3];

    // Pass-through parsers for round-trip
    when(() => mockItemParser.encode(any())).thenAnswer(
        (invocation) => invocation.positionalArguments.first as int);
    when(() => mockItemParser.decode(any())).thenAnswer(
        (invocation) => invocation.positionalArguments.first as int);

    final encoded = sut.encode(items);
    final decoded = sut.decode(encoded);
    final reEncoded = sut.encode(decoded);

    expect(decoded, items);
    expect(reEncoded, items);
  });
}
