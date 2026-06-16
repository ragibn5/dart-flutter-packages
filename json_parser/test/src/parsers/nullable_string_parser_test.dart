import 'package:json_parser/src/parsers/nullable_string_parser.dart';
import 'package:test/test.dart';

void main() {
  late NullableStringParser sut;

  setUp(() {
    sut = const NullableStringParser();
  });

  test('decode() should throw if passed value is not a nullable string', () {
    final invalidInputs = [123, 1.23, true, [], {}, Object()];

    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() returns the same value if it is a valid nullable string', () {
    const String? v1 = null;
    const v2 = 'abc';

    expect(sut.decode(v1), v1);
    expect(sut.decode(v2), v2);
  });

  test('encode() returns the same value', () {
    const String? v1 = null;
    const v2 = 'abc';

    expect(sut.encode(v1), v1);
    expect(sut.encode(v2), v2);
  });

  test('round-trip encode → decode → encode preserves values', () {
    final values = [null, '', 'hello', '123'];

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
