import 'package:json_parser/json_parser.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late NumParser sut;

  setUp(() {
    sut = const NumParser();
  });

  test('decode() should throw if passed any non-num value', () {
    final invalidInputs = ['string', true, <dynamic>[], <dynamic>{}, null];
    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<JsonParseException>()));
    }
  });

  test('decode() returns the same value if passed an int', () {
    const v = 123;
    expect(sut.decode(v), v);
    expect(sut.decode(v), isA<int>());
  });

  test('decode() returns the same value if passed a double', () {
    const v = 123.4;
    expect(sut.decode(v), v);
    expect(sut.decode(v), isA<double>());
  });

  test('encode() returns the same value', () {
    const v = 123.4;
    expect(sut.encode(v), v);
  });

  test('round-trip encode → decode should preserve values', () {
    final values = <num>[0, 0.0, 1.1, 123, 99.99];
    for (final value in values) {
      final encoded = sut.encode(value);
      final decoded = sut.decode(encoded);
      expect(decoded, value);
      expect(decoded.runtimeType, value.runtimeType);
    }
  });
}
