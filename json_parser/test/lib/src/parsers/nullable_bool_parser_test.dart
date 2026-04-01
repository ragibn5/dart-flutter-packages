import 'package:json_parser/src/parsers/nullable_bool_parser.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late NullableBoolParser sut;

  setUp(() {
    sut = const NullableBoolParser();
  });

  test('decode() should throw if passed a non-boolean, non-null value', () {
    final invalidInputs = ['string', 123, 1.23, <dynamic>[], <dynamic>{}];

    for (final input in invalidInputs) {
      expect(() => sut.decode(input), throwsA(isA<StateError>()));
    }
  });

  test(
      'decode() should return the same value if it is a valid nullable boolean',
      () {
    const v1 = null;
    const v2 = true;
    const v3 = false;

    expect(sut.decode(v1), v1);
    expect(sut.decode(v2), v2);
    expect(sut.decode(v3), v3);
  });

  test('encode() should return the same value', () {
    const bool? v1 = null;
    const v2 = true;
    const v3 = false;

    expect(sut.encode(v1), v1);
    expect(sut.encode(v2), v2);
    expect(sut.encode(v3), v3);
  });

  test('round-trip encode → decode → encode preserves value', () {
    const values = true;
    final encoded = sut.encode(values);
    final decoded = sut.decode(encoded);
    final reEncoded = sut.encode(decoded);

    expect(encoded, values);
    expect(decoded, values);
    expect(reEncoded, values);

    const bool? nullValue = null;
    final encodedNull = sut.encode(nullValue);
    final decodedNull = sut.decode(encodedNull);
    final reEncodedNull = sut.encode(decodedNull);

    expect(encodedNull, nullValue);
    expect(decodedNull, nullValue);
    expect(reEncodedNull, nullValue);
  });
}
