import 'package:json_parser/src/parsers/nullable_num_parser.dart';
import 'package:test/test.dart';

void main() {
  late NullableNumParser sut;

  setUp(() {
    sut = const NullableNumParser();
  });

  test('decode() should throw if passed value is not a number or null', () {
    final invalidInputs = ['string', true, <dynamic>[], <dynamic>{}];

    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() returns the same value if it is a valid nullable num', () {
    const num? v1 = null;
    const v2 = 123.4;
    expect(sut.decode(v1), v1);
    expect(sut.decode(v2), v2);
  });

  test('decode() passes null through and preserves int/double types', () {
    expect(sut.decode(null), isNull);
    expect(sut.decode(123), isA<int>());
    expect(sut.decode(123), 123);
    expect(sut.decode(123.4), isA<double>());
    expect(sut.decode(123.4), 123.4);
  });

  test('encode() returns the same value', () {
    const num? v1 = null;
    const v2 = 123.4;
    expect(sut.encode(v1), v1);
    expect(sut.encode(v2), v2);
  });

  test('round-trip encode → decode → encode preserves value', () {
    final values = <num?>[null, 0, 0.0, 123.4];

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
