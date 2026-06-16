import 'package:json_parser/src/parsers/nullable_double_parser.dart';
import 'package:test/test.dart';

void main() {
  late NullableDoubleParser sut;

  setUp(() {
    sut = const NullableDoubleParser();
  });

  test('decode() should throw if passed value is not a number or null', () {
    final invalidInputs = ['string', true, <dynamic>[], <dynamic>{}];

    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() returns the same value if it is a valid nullable double', () {
    const double? v1 = null;
    const v2 = 123.4;
    expect(sut.decode(v1), v1);
    expect(sut.decode(v2), v2);
  });

  test('decode() parses int to double and passes null', () {
    expect(sut.decode(null), isNull);
    expect(sut.decode(123), 123.0);
    expect(sut.decode(0), 0.0);
  });

  test('encode() returns the same value', () {
    const double? v1 = null;
    const v2 = 123.4;
    expect(sut.encode(v1), v1);
    expect(sut.encode(v2), v2);
  });

  test('round-trip encode → decode → encode preserves value', () {
    final values = [null, 0.0, 123.4];

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
