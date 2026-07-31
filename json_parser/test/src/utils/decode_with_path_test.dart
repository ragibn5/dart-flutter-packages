import 'package:json_parser/src/errors/json_parse_exception.dart';
import 'package:json_parser/src/utils/decode_with_path.dart';
import 'package:test/test.dart';

void main() {
  test('returns the result when decode succeeds', () {
    expect(decodeWithPath(() => 42, 'key'), 42);
  });

  test('prepends the segment to an existing path', () {
    expect(
      () => decodeWithPath(
        () => throw JsonParseException('Expected int', [1, 2]),
        3,
      ),
      throwsA(
        isA<JsonParseException>()
            .having((e) => e.message, 'message', 'Expected int')
            .having((e) => e.path, 'path', [3, 1, 2]),
      ),
    );
  });

  test('does not catch plain StateError', () {
    expect(
      () => decodeWithPath(() => throw StateError('boom'), 'x'),
      throwsA(isA<StateError>()),
    );
  });

  test('does not catch non-StateError exceptions', () {
    expect(
      () => decodeWithPath(() => throw ArgumentError('boom'), 'x'),
      throwsArgumentError,
    );
  });
}
