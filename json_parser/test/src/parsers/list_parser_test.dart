import 'package:json_parser/json_parser.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockItemParser extends Mock implements IntParser {}

void main() {
  late _MockItemParser mockItemParser;

  late ListParser<int> sut;

  setUp(() {
    mockItemParser = _MockItemParser();

    sut = ListParser(mockItemParser);
  });

  test('decode() should throw if passed value is not a List', () {
    final invalidInputs = ['string', 123, 1.23, <dynamic>{}, true, null];
    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() should call item parser for each element', () {
    final items = [1, 2, 3];

    when(() => mockItemParser.decode(any())).thenAnswer(
      (invocation) => (invocation.positionalArguments.first as int) * 10,
    );

    final result = sut.decode(items);

    verify(() => mockItemParser.decode(any())).called(items.length);
    expect(result, [10, 20, 30]);
  });

  test('decode() should handle empty list', () {
    final items = <int>[];
    final result = sut.decode(items);

    expect(result, isEmpty);
    verifyNever(() => mockItemParser.decode(any()));
  });

  test('decode() should handle single-element list', () {
    final items = [42];
    when(() => mockItemParser.decode(42)).thenReturn(99);

    final result = sut.decode(items);

    expect(result, [99]);
    verify(() => mockItemParser.decode(42)).called(1);
  });

  test('encode() should call item parser for each element', () {
    final items = [1, 2, 3];

    when(() => mockItemParser.encode(any())).thenAnswer(
      (invocation) => (invocation.positionalArguments.first as int) * 10,
    );

    final result = sut.encode(items);

    verify(() => mockItemParser.encode(any())).called(items.length);
    expect(result, [10, 20, 30]);
  });

  test('encode() should handle empty list', () {
    final items = <int>[];
    final result = sut.encode(items);

    expect(result, isEmpty);
    verifyNever(() => mockItemParser.encode(any()));
  });

  test('encode() should handle single-element list', () {
    final items = [42];
    when(() => mockItemParser.encode(42)).thenReturn(99);

    final result = sut.encode(items);

    expect(result, [99]);
    verify(() => mockItemParser.encode(42)).called(1);
  });

  test('round-trip encode → decode should preserve values', () {
    final items = [1, 2, 3];

    when(() => mockItemParser.encode(any())).thenAnswer(
      (invocation) => invocation.positionalArguments.first as int,
    );
    when(() => mockItemParser.decode(any())).thenAnswer(
      (invocation) => invocation.positionalArguments.first as int,
    );

    final encoded = sut.encode(items);
    final decoded = sut.decode(encoded);

    expect(decoded, items);
  });
}
