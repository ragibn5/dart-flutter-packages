import 'package:json_parser/json_parser.dart';
import 'package:test/test.dart';

void main() {
  late IntParser sut;

  setUp(() {
    sut = const IntParser();
  });

  test('decode() should throw if passed any non-num value', () {
    final invalidInputs = ['string', true, <dynamic>[], <dynamic>{}, null];
    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() returns the same value if passed an int', () {
    const v = 123;
    expect(sut.decode(v), v);
  });

  test('decode() parses double to int correctly (truncates)', () {
    expect(sut.decode(123.0), 123);
    expect(sut.decode(123.2), 123);
    expect(sut.decode(123.5), 123);
    expect(sut.decode(123.7), 123);
    expect(sut.decode(0.0), 0);
  });

  test('encode() returns the same value', () {
    const v = 123;
    expect(sut.encode(v), v);
  });

  test('round-trip encode → decode should preserve values', () {
    final intValues = [0, 1, 123, 9999, -42];
    for (final value in intValues) {
      final encoded = sut.encode(value);
      final decoded = sut.decode(encoded);
      expect(decoded, value);
    }

    // Also test doubles that truncate
    final doubleValues = [0.0, 1.9, 123.7, -42.3];
    for (final value in doubleValues) {
      final decoded = sut.decode(value);
      expect(decoded, value.toInt());
    }
  });
}
