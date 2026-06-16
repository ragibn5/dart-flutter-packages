import 'package:json_parser/json_parser.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late BoolParser sut;

  setUp(() {
    sut = const BoolParser();
  });

  test('decode() should throw if passed any non-bool value', () {
    final invalidInputs = ['string', 123, 1.23, [], {}, null];
    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test('decode() returns the same value if it is a valid boolean', () {
    const v1 = true;
    const v2 = false;
    expect(sut.decode(v1), v1);
    expect(sut.decode(v2), v2);
  });

  test('encode() returns the same value', () {
    const v1 = true;
    const v2 = false;
    expect(sut.encode(v1), v1);
    expect(sut.encode(v2), v2);
  });

  test('round-trip encode → decode should preserve values', () {
    const values = [true, false];
    for (final value in values) {
      final encoded = sut.encode(value);
      final decoded = sut.decode(encoded);
      expect(decoded, value);
    }
  });
}
