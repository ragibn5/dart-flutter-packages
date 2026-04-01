import 'package:json_parser/src/parsers/nullable_int_parser.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late NullableIntParser sut;

  setUp(() {
    sut = const NullableIntParser();
  });

  test('decode() should throw if passed value is not a number or null', () {
    final invalidInputs = ['string', true, <dynamic>[], <dynamic>{}];

    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() returns the same value if it is a valid nullable int', () {
    const int? v1 = null;
    const v2 = 123;

    expect(sut.decode(v1), v1);
    expect(sut.decode(v2), v2);
  });

  test('decode() parses doubles to int and passes null', () {
    expect(sut.decode(null), isNull);
    expect(sut.decode(123.0), 123);
    expect(sut.decode(123.2), 123);
    expect(sut.decode(123.5), 123);
    expect(sut.decode(123.7), 123);
  });

  test('encode() returns the same value', () {
    const int? v1 = null;
    const v2 = 123;

    expect(sut.encode(v1), v1);
    expect(sut.encode(v2), v2);
  });

  test('round-trip encode → decode → encode preserves value', () {
    final values = [null, 0, 123];

    for (final value in values) {
      final encoded = sut.encode(value);
      final decoded = sut.decode(encoded);
      final reEncoded = sut.encode(decoded);

      expect(decoded, value);
      expect(encoded, value);
      expect(reEncoded, value);
    }
  });
}
