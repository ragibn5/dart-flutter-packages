import 'package:json_parser/json_parser.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late DoubleParser sut;

  setUp(() {
    sut = const DoubleParser();
  });

  test('decode() should throw if passed any non-num value', () {
    final invalidInputs = ['string', true, <dynamic>[], <dynamic>{}, null];
    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() returns the same value if passed a double', () {
    const v = 123.4;
    expect(sut.decode(v), v);
  });

  test('decode() parses int to double correctly', () {
    expect(sut.decode(123), 123.0);
    expect(sut.decode(0), 0.0);
  });

  test('encode() returns the same value', () {
    const v = 123.4;
    expect(sut.encode(v), v);
  });

  test('round-trip encode → decode should preserve values', () {
    final values = [0.0, 1.1, 123.4, 99.99];
    for (final value in values) {
      final encoded = sut.encode(value);
      final decoded = sut.decode(encoded);
      expect(decoded, value);
    }

    // Also check int values convert properly
    final intValues = [0, 1, 123, 99];
    for (final value in intValues) {
      final encoded = sut.encode(value.toDouble());
      final decoded = sut.decode(encoded);
      expect(decoded, value.toDouble());
    }
  });
}
