import 'package:json_parser/json_parser.dart';
import 'package:test/test.dart';

void main() {
  late StringParser sut;

  setUp(() {
    sut = const StringParser();
  });

  test('decode() should throw if passed value is not a string', () {
    final invalidInputs = [
      123,
      1.23,
      true,
      <dynamic>[],
      <dynamic>{},
      Object(),
      null
    ];

    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() returns the same value if it is a valid string', () {
    const v1 = 'qwerty';
    const v2 = '';

    expect(sut.decode(v1), v1);
    expect(sut.decode(v2), v2);
  });

  test('encode() returns the same value', () {
    const v1 = 'qwerty';
    const v2 = '';

    expect(sut.encode(v1), v1);
    expect(sut.encode(v2), v2);
  });

  test('round-trip encode → decode → encode preserves values', () {
    final values = ['abc', '', '123', '😊'];

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
